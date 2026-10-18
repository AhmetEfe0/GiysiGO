using System.Data;
using Microsoft.Data.SqlClient;

namespace GiysiGo.Modules.Ordering.Tests
{
    public sealed class OrderingSqlServerRegressionTests
    {
        private const string ConnectionStringVariable = "GIYSIGO_ORDERING_TEST_CONNECTION_STRING";

        [SqlServerFact]
        public async Task Quote_edit_and_publish_serialize_and_published_quote_cannot_be_changed()
        {
            var connectionString = RequireConnectionString();
            var fixture = await CreateFixtureAsync(connectionString, "AWAITING_STORE_APPROVAL", "DRAFT");
            try
            {
                await using var editConnection = new SqlConnection(connectionString);
                await editConnection.OpenAsync();
                await using var editTransaction = (SqlTransaction)await editConnection.BeginTransactionAsync();
                await ExecuteProcedureAsync(editConnection, editTransaction, "[ordering].[spSetDraftQuoteLine]",
                    ("@QuoteId", fixture.QuoteId), ("@StoreId", fixture.StoreId), ("@OrderItemServiceId", fixture.OrderItemServiceId),
                    ("@UnitPrice", 999m), ("@PriceUnit", "PIECE"), ("@Quantity", 1m), ("@Explanation", "serialized edit"));

                var publisherStarted = new TaskCompletionSource<bool>(TaskCreationOptions.RunContinuationsAsynchronously);
                var publishTask = Task.Run(async () =>
                {
                    await using var publishConnection = new SqlConnection(connectionString);
                    await publishConnection.OpenAsync();
                    await using var publishTransaction = (SqlTransaction)await publishConnection.BeginTransactionAsync();
                    publisherStarted.SetResult(true);
                    await ExecuteProcedureAsync(publishConnection, publishTransaction, "[ordering].[spSubmitQuoteForApproval]",
                        ("@QuoteId", fixture.QuoteId), ("@StoreId", fixture.StoreId), ("@ActorUserId", fixture.ActorUserId));
                    await ExecuteProcedureAsync(publishConnection, publishTransaction, "[ordering].[spApproveAndPublishQuote]",
                        ("@QuoteId", fixture.QuoteId), ("@StoreId", fixture.StoreId), ("@ActorUserId", fixture.ActorUserId));
                    await publishTransaction.CommitAsync();
                });

                await publisherStarted.Task.WaitAsync(TimeSpan.FromSeconds(5));
                await Task.Delay(TimeSpan.FromMilliseconds(300));
                Assert.False(publishTask.IsCompleted, "Quote submission must wait for the in-flight draft edit.");

                await editTransaction.CommitAsync();
                await publishTask.WaitAsync(TimeSpan.FromSeconds(10));

                await using var verifyConnection = new SqlConnection(connectionString);
                await verifyConnection.OpenAsync();
                var publishedTotal = await ScalarAsync<decimal>(verifyConnection, null,
                    "SELECT total_amount FROM [ordering].price_quotes WHERE id = @QuoteId AND status = 'PUBLISHED';",
                    ("@QuoteId", fixture.QuoteId));
                Assert.Equal(999m, publishedTotal);

                await Assert.ThrowsAsync<SqlException>(() => ExecuteProcedureAsync(verifyConnection, null, "[ordering].[spSetDraftQuoteLine]",
                    ("@QuoteId", fixture.QuoteId), ("@StoreId", fixture.StoreId), ("@OrderItemServiceId", fixture.OrderItemServiceId),
                    ("@UnitPrice", 444m), ("@PriceUnit", "PIECE"), ("@Quantity", 1m), ("@Explanation", "must be rejected")));

                var unchangedTotal = await ScalarAsync<decimal>(verifyConnection, null,
                    "SELECT total_amount FROM [ordering].price_quotes WHERE id = @QuoteId;", ("@QuoteId", fixture.QuoteId));
                Assert.Equal(999m, unchangedTotal);
            }
            finally
            {
                await CleanupFixtureAsync(connectionString, fixture);
            }
        }

        [SqlServerFact]
        public async Task Checkout_uses_one_locked_price_snapshot_for_total_and_service_rows()
        {
            var connectionString = RequireConnectionString();
            var fixture = await CreateFixtureAsync(connectionString);
            try
            {
                await using var checkoutConnection = new SqlConnection(connectionString);
                await checkoutConnection.OpenAsync();
                await using var checkoutTransaction = (SqlTransaction)await checkoutConnection.BeginTransactionAsync();
                await ExecuteProcedureAsync(checkoutConnection, checkoutTransaction, "[ordering].[spCheckoutCart]",
                    ("@CartId", fixture.CartId), ("@CustomerId", fixture.CustomerId),
                    ("@IdempotencyKey", $"checkout-{fixture.CartId:N}"), ("@ExpectedCartVersion", 0));

                var updateStarted = new TaskCompletionSource<bool>(TaskCreationOptions.RunContinuationsAsynchronously);
                var tariffUpdateTask = Task.Run(async () =>
                {
                    await using var updateConnection = new SqlConnection(connectionString);
                    await updateConnection.OpenAsync();
                    updateStarted.SetResult(true);
                    await ExecuteAsync(updateConnection, null,
                        "UPDATE [catalog].store_offerings SET price_override = 500 WHERE id = @OfferingId;",
                        ("@OfferingId", fixture.OfferingId));
                });

                await updateStarted.Task.WaitAsync(TimeSpan.FromSeconds(5));
                await Task.Delay(TimeSpan.FromMilliseconds(300));
                Assert.False(tariffUpdateTask.IsCompleted, "Tariff changes must wait until checkout commits its price snapshot.");

                await checkoutTransaction.CommitAsync();
                await tariffUpdateTask.WaitAsync(TimeSpan.FromSeconds(10));

                await using var verifyConnection = new SqlConnection(connectionString);
                await verifyConnection.OpenAsync();
                var totals = await ReadCheckoutTotalsAsync(verifyConnection, fixture.CartId);
                Assert.Equal(200m, totals.OrderTotal);
                Assert.Equal(totals.OrderTotal, totals.ServiceTotal);
                Assert.Equal(200m, totals.ServiceUnitPrice);
                Assert.Equal(500m, await ScalarAsync<decimal>(verifyConnection, null,
                    "SELECT price_override FROM [catalog].store_offerings WHERE id = @OfferingId;", ("@OfferingId", fixture.OfferingId)));
            }
            finally
            {
                await CleanupFixtureAsync(connectionString, fixture);
            }
        }

        [SqlServerFact]
        public async Task Payment_idempotency_returns_existing_attempt_only_to_owning_customer()
        {
            var connectionString = RequireConnectionString();
            var fixture = await CreateFixtureAsync(connectionString, "AWAITING_PAYMENT", "CUSTOMER_ACCEPTED");
            try
            {
                await using var connection = new SqlConnection(connectionString);
                await connection.OpenAsync();
                var parameters = new (string Name, object? Value)[]
                {
                    ("@OrderId", fixture.OrderId), ("@QuoteId", fixture.QuoteId), ("@CustomerId", fixture.CustomerId),
                    ("@Provider", "ordering-regression"), ("@IdempotencyKey", $"payment-{fixture.QuoteId:N}")
                };
                var firstAttempt = await ProcedureScalarAsync<Guid>(connection, null, "[ordering].[spBeginPaymentAttempt]", parameters);
                var retryAttempt = await ProcedureScalarAsync<Guid>(connection, null, "[ordering].[spBeginPaymentAttempt]", parameters);
                Assert.Equal(firstAttempt, retryAttempt);

                var otherCustomerParameters = parameters
                    .Select(parameter => parameter.Name == "@CustomerId" ? (parameter.Name, (object?)fixture.OtherCustomerId) : parameter)
                    .ToArray();
                await Assert.ThrowsAsync<SqlException>(() => ProcedureScalarAsync<Guid>(connection, null,
                    "[ordering].[spBeginPaymentAttempt]", otherCustomerParameters));
            }
            finally
            {
                await CleanupFixtureAsync(connectionString, fixture);
            }
        }

        private static string RequireConnectionString()
        {
            var connectionString = Environment.GetEnvironmentVariable(ConnectionStringVariable);
            if (string.IsNullOrWhiteSpace(connectionString))
                throw new InvalidOperationException($"Set {ConnectionStringVariable} to a dedicated SQL Server test database with the GiysiGo DACPAC deployed.");
            return connectionString;
        }

        private static async Task<(Guid CartId, Guid CustomerId, Guid OtherCustomerId, Guid ActorUserId, Guid CorporateId, Guid StoreId, Guid AddressId, Guid CategoryId, Guid ProductTypeId, Guid ServiceId, Guid ProductTypeServiceId, Guid OfferingId, Guid OrderId, Guid OrderItemServiceId, Guid QuoteId)> CreateFixtureAsync(
            string connectionString, string? orderStatus = null, string? quoteStatus = null)
        {
            var fixture = (CartId: Guid.NewGuid(), CustomerId: Guid.NewGuid(), OtherCustomerId: Guid.NewGuid(), ActorUserId: Guid.NewGuid(),
                CorporateId: Guid.NewGuid(), StoreId: Guid.NewGuid(), AddressId: Guid.NewGuid(), CategoryId: Guid.NewGuid(),
                ProductTypeId: Guid.NewGuid(), ServiceId: Guid.NewGuid(), ProductTypeServiceId: Guid.NewGuid(), OfferingId: Guid.NewGuid(),
                CartItemId: Guid.NewGuid(), CartItemServiceId: Guid.NewGuid(), OrderId: Guid.NewGuid(), OrderItemId: Guid.NewGuid(),
                OrderItemServiceId: Guid.NewGuid(), QuoteId: Guid.NewGuid());
            await using var connection = new SqlConnection(connectionString);
            await connection.OpenAsync();
            await using var transaction = (SqlTransaction)await connection.BeginTransactionAsync();

            foreach (var userId in new[] { fixture.CustomerId, fixture.OtherCustomerId, fixture.ActorUserId })
            {
                await ExecuteAsync(connection, transaction,
                    "INSERT [identity].users (id, email, password_hash) VALUES (@Id, @Email, N'test-only');",
                    ("@Id", userId), ("@Email", $"ordering-test-{userId:N}@example.test"));
            }
            await ExecuteAsync(connection, transaction,
                "INSERT [identity].corporates (id, name) VALUES (@Id, N'Ordering regression test');",
                ("@Id", fixture.CorporateId));
            await ExecuteAsync(connection, transaction,
                "INSERT [catalog].stores (id, corporate_id, name, address_text, latitude, longitude, service_radius_km) VALUES (@Id, @CorporateId, N'Ordering regression store', N'Test', 41, 29, 10);",
                ("@Id", fixture.StoreId), ("@CorporateId", fixture.CorporateId));
            await ExecuteAsync(connection, transaction,
                "INSERT [identity].customer_addresses (id, user_id, label, address_text, latitude, longitude, contact_name, contact_phone) VALUES (@Id, @UserId, N'Test', N'Test address', 41, 29, N'Test', N'+900000000000');",
                ("@Id", fixture.AddressId), ("@UserId", fixture.CustomerId));
            await ExecuteAsync(connection, transaction,
                "INSERT [catalog].product_categories (id, code, name) VALUES (@Id, @Code, N'Test category');",
                ("@Id", fixture.CategoryId), ("@Code", $"test-category-{fixture.CategoryId:N}"));
            await ExecuteAsync(connection, transaction,
                "INSERT [catalog].product_types (id, category_id, code, name, base_unit) VALUES (@Id, @CategoryId, @Code, N'Test garment', N'PIECE');",
                ("@Id", fixture.ProductTypeId), ("@CategoryId", fixture.CategoryId), ("@Code", $"test-product-{fixture.ProductTypeId:N}"));
            await ExecuteAsync(connection, transaction,
                "INSERT [catalog].services (id, code, name) VALUES (@Id, @Code, N'Test cleaning');",
                ("@Id", fixture.ServiceId), ("@Code", $"test-service-{fixture.ServiceId:N}"));
            await ExecuteAsync(connection, transaction,
                "INSERT [catalog].product_type_services (id, product_type_id, service_id, default_price, price_unit, selection_kind) VALUES (@Id, @ProductTypeId, @ServiceId, 300, N'PIECE', N'BASE');",
                ("@Id", fixture.ProductTypeServiceId), ("@ProductTypeId", fixture.ProductTypeId), ("@ServiceId", fixture.ServiceId));
            await ExecuteAsync(connection, transaction,
                "INSERT [catalog].store_offerings (id, store_id, product_type_service_id, price_override) VALUES (@Id, @StoreId, @ProductTypeServiceId, 200);",
                ("@Id", fixture.OfferingId), ("@StoreId", fixture.StoreId), ("@ProductTypeServiceId", fixture.ProductTypeServiceId));
            await ExecuteAsync(connection, transaction,
                "INSERT [ordering].carts (id, customer_id, store_id, address_id, pickup_window_start, pickup_window_end) VALUES (@Id, @CustomerId, @StoreId, @AddressId, DATEADD(day, 1, SYSUTCDATETIME()), DATEADD(day, 2, SYSUTCDATETIME()));",
                ("@Id", fixture.CartId), ("@CustomerId", fixture.CustomerId), ("@StoreId", fixture.StoreId), ("@AddressId", fixture.AddressId));
            await ExecuteAsync(connection, transaction,
                "INSERT [ordering].cart_items (id, cart_id, product_type_id, customer_note) VALUES (@Id, @CartId, @ProductTypeId, N'regression');",
                ("@Id", fixture.CartItemId), ("@CartId", fixture.CartId), ("@ProductTypeId", fixture.ProductTypeId));
            await ExecuteAsync(connection, transaction,
                "INSERT [ordering].cart_item_services (id, cart_item_id, store_offering_id) VALUES (@Id, @CartItemId, @OfferingId);",
                ("@Id", fixture.CartItemServiceId), ("@CartItemId", fixture.CartItemId), ("@OfferingId", fixture.OfferingId));

            if (orderStatus is not null && quoteStatus is not null)
            {
                await ExecuteAsync(connection, transaction,
                    "INSERT [ordering].orders (id, source_cart_id, customer_id, store_id, pickup_window_start, pickup_window_end, status, estimated_total, idempotency_key) VALUES (@Id, @CartId, @CustomerId, @StoreId, DATEADD(day, 1, SYSUTCDATETIME()), DATEADD(day, 2, SYSUTCDATETIME()), @Status, 200, @IdempotencyKey);",
                    ("@Id", fixture.OrderId), ("@CartId", fixture.CartId), ("@CustomerId", fixture.CustomerId),
                    ("@StoreId", fixture.StoreId), ("@Status", orderStatus), ("@IdempotencyKey", $"order-{fixture.OrderId:N}"));
                await ExecuteAsync(connection, transaction,
                    "INSERT [ordering].order_items (id, order_id, product_type_id, product_type_name_snapshot, tracking_code, inspection_status) VALUES (@Id, @OrderId, @ProductTypeId, N'Test garment', @TrackingCode, N'ACCEPTED');",
                    ("@Id", fixture.OrderItemId), ("@OrderId", fixture.OrderId), ("@ProductTypeId", fixture.ProductTypeId), ("@TrackingCode", $"test-{fixture.OrderItemId:N}"));
                await ExecuteAsync(connection, transaction,
                    "INSERT [ordering].order_item_services (id, order_item_id, product_type_service_id, service_name_snapshot, estimated_unit_price, price_unit_snapshot, estimated_quantity, estimated_price) VALUES (@Id, @OrderItemId, @ProductTypeServiceId, N'Test cleaning', 200, N'PIECE', 1, 200);",
                    ("@Id", fixture.OrderItemServiceId), ("@OrderItemId", fixture.OrderItemId), ("@ProductTypeServiceId", fixture.ProductTypeServiceId));
                await ExecuteAsync(connection, transaction,
                    "INSERT [ordering].price_quotes (id, order_id, revision, status, subtotal, total_amount, customer_decision_by, customer_decision_at) VALUES (@Id, @OrderId, 1, @Status, 200, 200, CASE WHEN @Status = N'CUSTOMER_ACCEPTED' THEN @CustomerId END, CASE WHEN @Status = N'CUSTOMER_ACCEPTED' THEN SYSUTCDATETIME() END);",
                    ("@Id", fixture.QuoteId), ("@OrderId", fixture.OrderId), ("@Status", quoteStatus), ("@CustomerId", fixture.CustomerId));
                await ExecuteAsync(connection, transaction,
                    "INSERT [ordering].price_quote_lines (id, price_quote_id, order_item_service_id, service_name_snapshot, unit_price, price_unit, quantity, amount) VALUES (@Id, @QuoteId, @OrderItemServiceId, N'Test cleaning', 200, N'PIECE', 1, 200);",
                    ("@Id", Guid.NewGuid()), ("@QuoteId", fixture.QuoteId), ("@OrderItemServiceId", fixture.OrderItemServiceId));
            }

            await transaction.CommitAsync();
            return (fixture.CartId, fixture.CustomerId, fixture.OtherCustomerId, fixture.ActorUserId, fixture.CorporateId,
                fixture.StoreId, fixture.AddressId, fixture.CategoryId, fixture.ProductTypeId, fixture.ServiceId,
                fixture.ProductTypeServiceId, fixture.OfferingId, fixture.OrderId, fixture.OrderItemServiceId, fixture.QuoteId);
        }

        private static async Task CleanupFixtureAsync(string connectionString,
            (Guid CartId, Guid CustomerId, Guid OtherCustomerId, Guid ActorUserId, Guid CorporateId, Guid StoreId, Guid AddressId, Guid CategoryId, Guid ProductTypeId, Guid ServiceId, Guid ProductTypeServiceId, Guid OfferingId, Guid OrderId, Guid OrderItemServiceId, Guid QuoteId) fixture)
        {
            await using var connection = new SqlConnection(connectionString);
            await connection.OpenAsync();
            await ExecuteAsync(connection, null, ""
                + "DELETE FROM [ordering].payment_attempts WHERE order_id IN (SELECT id FROM [ordering].orders WHERE source_cart_id = @CartId); "
                + "DELETE FROM [ordering].quote_approval_history WHERE price_quote_id IN (SELECT q.id FROM [ordering].price_quotes q JOIN [ordering].orders o ON o.id = q.order_id WHERE o.source_cart_id = @CartId); "
                + "DELETE FROM [ordering].price_quote_lines WHERE price_quote_id IN (SELECT q.id FROM [ordering].price_quotes q JOIN [ordering].orders o ON o.id = q.order_id WHERE o.source_cart_id = @CartId); "
                + "DELETE FROM [ordering].price_quotes WHERE order_id IN (SELECT id FROM [ordering].orders WHERE source_cart_id = @CartId); "
                + "DELETE FROM [ordering].order_item_services WHERE order_item_id IN (SELECT id FROM [ordering].order_items WHERE order_id IN (SELECT id FROM [ordering].orders WHERE source_cart_id = @CartId)); "
                + "DELETE FROM [ordering].order_item_photos WHERE order_item_id IN (SELECT id FROM [ordering].order_items WHERE order_id IN (SELECT id FROM [ordering].orders WHERE source_cart_id = @CartId)); "
                + "DELETE FROM [ordering].order_items WHERE order_id IN (SELECT id FROM [ordering].orders WHERE source_cart_id = @CartId); "
                + "DELETE FROM [ordering].order_address_snapshots WHERE order_id IN (SELECT id FROM [ordering].orders WHERE source_cart_id = @CartId); "
                + "DELETE FROM [ordering].order_status_history WHERE order_id IN (SELECT id FROM [ordering].orders WHERE source_cart_id = @CartId); "
                + "DELETE FROM [ordering].orders WHERE source_cart_id = @CartId; "
                + "DELETE FROM [ordering].cart_item_photos WHERE cart_item_id IN (SELECT id FROM [ordering].cart_items WHERE cart_id = @CartId); "
                + "DELETE FROM [ordering].cart_item_services WHERE cart_item_id IN (SELECT id FROM [ordering].cart_items WHERE cart_id = @CartId); "
                + "DELETE FROM [ordering].cart_items WHERE cart_id = @CartId; "
                + "DELETE FROM [ordering].carts WHERE id = @CartId; "
                + "DELETE FROM [catalog].store_offerings WHERE id = @OfferingId; "
                + "DELETE FROM [catalog].product_type_services WHERE id = @ProductTypeServiceId; "
                + "DELETE FROM [catalog].services WHERE id = @ServiceId; "
                + "DELETE FROM [catalog].product_types WHERE id = @ProductTypeId; "
                + "DELETE FROM [catalog].product_categories WHERE id = @CategoryId; "
                + "DELETE FROM [catalog].stores WHERE id = @StoreId; "
                + "DELETE FROM [identity].customer_addresses WHERE id = @AddressId; "
                + "DELETE FROM [identity].corporates WHERE id = @CorporateId; "
                + "DELETE FROM [identity].users WHERE id IN (@CustomerId, @OtherCustomerId, @ActorUserId);",
                ("@CartId", fixture.CartId),
                ("@OfferingId", fixture.OfferingId), ("@ProductTypeServiceId", fixture.ProductTypeServiceId),
                ("@ServiceId", fixture.ServiceId), ("@ProductTypeId", fixture.ProductTypeId),
                ("@CategoryId", fixture.CategoryId), ("@StoreId", fixture.StoreId), ("@AddressId", fixture.AddressId),
                ("@CorporateId", fixture.CorporateId), ("@CustomerId", fixture.CustomerId),
                ("@OtherCustomerId", fixture.OtherCustomerId), ("@ActorUserId", fixture.ActorUserId));
        }

        private static async Task ExecuteProcedureAsync(SqlConnection connection, SqlTransaction? transaction, string procedureName,
            params (string Name, object? Value)[] parameters)
        {
            await using var command = new SqlCommand(procedureName, connection, transaction) { CommandType = CommandType.StoredProcedure };
            AddParameters(command, parameters);
            await command.ExecuteNonQueryAsync();
        }

        private static async Task<T> ProcedureScalarAsync<T>(SqlConnection connection, SqlTransaction? transaction, string procedureName,
            params (string Name, object? Value)[] parameters)
        {
            await using var command = new SqlCommand(procedureName, connection, transaction) { CommandType = CommandType.StoredProcedure };
            AddParameters(command, parameters);
            return (T)(await command.ExecuteScalarAsync())!;
        }

        private static async Task ExecuteAsync(SqlConnection connection, SqlTransaction? transaction, string sql,
            params (string Name, object? Value)[] parameters)
        {
            await using var command = new SqlCommand(sql, connection, transaction);
            AddParameters(command, parameters);
            await command.ExecuteNonQueryAsync();
        }

        private static async Task<T> ScalarAsync<T>(SqlConnection connection, SqlTransaction? transaction, string sql,
            params (string Name, object? Value)[] parameters)
        {
            await using var command = new SqlCommand(sql, connection, transaction);
            AddParameters(command, parameters);
            var value = await command.ExecuteScalarAsync();
            return (T)Convert.ChangeType(value!, typeof(T), System.Globalization.CultureInfo.InvariantCulture);
        }

        private static async Task<(decimal OrderTotal, decimal ServiceTotal, decimal ServiceUnitPrice)> ReadCheckoutTotalsAsync(SqlConnection connection, Guid cartId)
        {
            await using var command = new SqlCommand(""
                + "SELECT o.estimated_total, SUM(ois.estimated_price), MIN(ois.estimated_unit_price) "
                + "FROM [ordering].orders o JOIN [ordering].order_items oi ON oi.order_id = o.id "
                + "JOIN [ordering].order_item_services ois ON ois.order_item_id = oi.id "
                + "WHERE o.source_cart_id = @CartId GROUP BY o.estimated_total;", connection);
            command.Parameters.AddWithValue("@CartId", cartId);
            await using var reader = await command.ExecuteReaderAsync();
            Assert.True(await reader.ReadAsync(), "Checkout should create the order and service snapshots.");
            return (reader.GetDecimal(0), reader.GetDecimal(1), reader.GetDecimal(2));
        }

        private static void AddParameters(SqlCommand command, IEnumerable<(string Name, object? Value)> parameters)
        {
            foreach (var (name, value) in parameters)
                command.Parameters.AddWithValue(name, value ?? DBNull.Value);
        }
    }
}

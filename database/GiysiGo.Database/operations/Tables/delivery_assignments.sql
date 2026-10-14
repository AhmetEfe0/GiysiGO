-- operations.delivery_assignments
CREATE TABLE [operations].delivery_assignments (
    id uniqueidentifier PRIMARY KEY,
    create_date datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
    update_date datetime2(7),
    delete_date datetime2(7),
    delivery_task_id uniqueidentifier NOT NULL REFERENCES [operations].delivery_tasks(id),
    courier_id uniqueidentifier NOT NULL REFERENCES [operations].courier_profiles(id),
    status nvarchar(40) NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'COMPLETED', 'CANCELLED')),
    assigned_at datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
    unassigned_at datetime2(7),
    assignment_reason nvarchar(max) NOT NULL,
    distance_km decimal(8,3) NOT NULL CHECK (distance_km >= 0),
    CHECK ((status = 'ACTIVE' AND unassigned_at IS NULL)
        OR (status <> 'ACTIVE' AND unassigned_at IS NOT NULL))
);
GO
CREATE UNIQUE INDEX ux_delivery_assignments_one_active_per_task
    ON [operations].delivery_assignments (delivery_task_id) WHERE status = 'ACTIVE';
GO
CREATE INDEX ix_delivery_assignments_courier_active
    ON [operations].delivery_assignments (courier_id) WHERE status = 'ACTIVE';
GO

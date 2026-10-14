-- operations.courier_profiles
CREATE TABLE [operations].courier_profiles (
    id uniqueidentifier PRIMARY KEY,
    create_date datetime2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
    update_date datetime2(7),
    delete_date datetime2(7),
    user_id uniqueidentifier UNIQUE REFERENCES [identity].users(id),
    display_name nvarchar(200) NOT NULL,
    is_mock bit NOT NULL DEFAULT 0,
    is_active bit NOT NULL DEFAULT 1,
    vehicle_type nvarchar(40) NOT NULL,
    capacity_units int NOT NULL CHECK (capacity_units > 0),
    latitude decimal(9,6) NOT NULL CHECK (latitude BETWEEN -90 AND 90),
    longitude decimal(9,6) NOT NULL CHECK (longitude BETWEEN -180 AND 180),
    max_task_radius_km decimal(7,2) NOT NULL CHECK (max_task_radius_km > 0),
    CHECK ((is_mock = 1 AND user_id IS NULL) OR (is_mock = 0 AND user_id IS NOT NULL))
);
GO

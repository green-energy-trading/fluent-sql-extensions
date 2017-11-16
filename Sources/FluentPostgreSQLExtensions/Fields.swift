import Fluent

extension Builder {
    /// Convenience to create timestamp fields.
    /// This will need a call to createUpdatedAtTrigger outside of the builder to create the trigger to set updated_at (PostgreSQL Only?)
    /// This has the minor side effect that every time this is called it updates the function that sets the timestamp
    /// It shouldn't do any damage, it's just slightly suboptimal when running preparations.
    public func createAutoTimestamps() {
        custom("created_at", type: "TIMESTAMP WITH TIME ZONE", optional: false, unique: false, default: "now()")
        custom("updated_at", type: "TIMESTAMP WITH TIME ZONE", optional: true, unique: false)
    }
}

extension Executor {
    /// Creates a SQL enum type with the specified values
    public func createEnum(
        withName name: String,
        values: String ...
        ) throws {
        
        let valueString = values.map({ "'\($0)'"}).joined(separator: ",").string
        try self.raw("CREATE TYPE \(name) AS ENUM (\(valueString));")
    }
    
    /// Drops a type with an optional cascade
    public func dropType(
        withName name: String,
        cascade: Bool = false
        ) throws {
        let cascadeCommand = cascade ? " CASCADE" : "";
        try self.raw("DROP TYPE IF EXISTS \(name)\(cascadeCommand);")
    }

    /// Creates a trigger for the given entity that will updated updated_at when a record is saved.
    /// Your application needs to create the trigger function (only once) within a preparation using createSetUpdatedAtFunction before this is called
    public func createUpdatedAtTrigger(on entity: String) throws {
        try self.raw("CREATE TRIGGER \(entity)_updated_at_trigger BEFORE UPDATE ON \(entity) FOR EACH ROW EXECUTE PROCEDURE set_updated_at();")
    }
    
    public func createSetUpdatedAtFunction() throws {
        try self.raw("""
            CREATE OR REPLACE FUNCTION set_updated_at()
            RETURNS TRIGGER AS $$
            BEGIN
                NEW.updated_at = now();
                RETURN NEW;
            END;
            $$ language 'plpgsql';
        """)
    }
}

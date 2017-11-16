import Fluent

extension Builder {
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
    
    /// Alters a table to add a field of the specific type. This uses raw SQL so that default functions etc can be used
    public func createField(
        on table: String,
        withName name: String,
        type: String,
        optional: Bool = false,
        defaultValue: String? = nil
        ) throws {
        let nullable = optional ? "" : " NOT NULL";
        let defaultClause = defaultValue == nil ? "" : " DEFAULT \(defaultValue!)";
        let query = "ALTER TABLE \(table) ADD COLUMN \(name) \(type)\(nullable)\(defaultClause);"
        try self.raw(query)
    }
    
    /// Alters a table to add a field of the specific type. This uses raw SQL so that default functions etc can be used
    public func createField(
        on entity: Entity,
        withName name: String,
        type dbType: String,
        optional: Bool = false,
        defaultValue: String? = nil
        ) throws {
        return try createField(on: type(of: entity).entity, withName: name, type: dbType, optional: optional, defaultValue: defaultValue)
    }
    
    /// Drops a type with an optional cascade
    public func dropType(
        withName name: String,
        cascade: Bool = false
        ) throws {
        let cascadeCommand = cascade ? " CASCADE" : "";
        try self.raw("DROP TYPE IF EXISTS \(name)\(cascadeCommand);")
    }
    
    /// Convenience to create timestamp fields with triggers (PostgreSQL Only?)
    public func createTimestamps(on table: String) throws {
        try createField(on: table, withName: "created_at", type: "TIMESTAMP WITH TIME ZONE", defaultValue: "now()")
        try createField(on: table, withName: "updated_at", type: "TIMESTAMP WITH TIME ZONE", optional: true)
        try self.raw("CREATE TRIGGER \(table)_updated_at_trigger BEFORE UPDATE ON \(table) FOR EACH ROW EXECUTE PROCEDURE set_updated_at();")
        
    }
    
    public func createTimestamps(on entity: Entity) throws {
        return try createTimestamps(on: type(of: entity).entity)
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

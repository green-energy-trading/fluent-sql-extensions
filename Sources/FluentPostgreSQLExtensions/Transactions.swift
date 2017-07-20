//
//  Transactions.swift
//  FluentSQLExtensions
//
//  Created by David Monagle on 13/7/17.
//
//

import Fluent
import Foundation
import FluentSQLExtensions

public enum PGIsolationLevel : String {
    case serializable = "SERIALIZABLE"
    case repeatableRead = "REPEATABLE READ"
    case readCommitted = "READ COMMITTED"
    case readUncommitted = " READ UNCOMMITTED"
}

public enum PGTransactionMode : CustomStringConvertible {
    case isolationLevel(PGIsolationLevel)
    case readWrite
    case readOnly
    case deferrable
    case notDeferrable
    
    public var description: String {
        switch self {
        case .isolationLevel(let level): return "ISOLATION LEVEL \(level)"
        case .readWrite: return "READ WRITE"
        case .readOnly: return "READ ONLY"
        case .deferrable: return "DEFERRABLE"
        case .notDeferrable: return "NOT DEFERRABLE"
        }
    }
}

extension Database {
    /// Create a transaction and set the specified transactionMode
    @discardableResult
    public func transaction<T>(transactionMode: PGTransactionMode, _ closure: @escaping (Connection) throws -> T) throws -> T {
        return try self.transaction() {
            connection in
            try connection.raw("SET TRANSACTION \(transactionMode);")
            return try closure(connection)
        }
    }

    @discardableResult
    public func transaction(transactionMode: PGTransactionMode, _ rawQuery: RawQuery) throws -> Node {
        return try self.transaction(transactionMode: transactionMode) {
            connection in
            return try connection.query(rawQuery)
        }
    }

}

//
//  RawQuery.swift
//  FluentSQLExtensions
//
//  Created by David Monagle on 14/7/17.
//

import Node
import Fluent

public enum RawQueryError : Error {
    case emptyStringIdentifier
}

/**
    Allows the building of a raw query with parameters. These can be used as filters or as direct
    queries on the database
 */
public struct RawQuery {
    public var query : String = ""
    public var parameters : [Node] = []
    
    public init() {
    }
    
    public init(_ query : String) {
        self.query = query
    }
    
    public mutating func append(_ q: String) {
        if q.isEmpty { return } // Do nothing if the query is empty
        
        // Add a space if required
        if let last = query.characters.last { // See if there are any characters yet
            if last != " " && q.characters.first! != " " {       // If the last character wasn't a space and neither is the first character of the exisitng query
                query.append(" ")
            }
        }
        
        query.append(q)
    }
    public mutating func addParameter(_ identifier: Identifier?) {
        var nodeValue : Node
        if let i = identifier {
            switch i.wrapped {
            case .string(let s):
                if s.isEmpty { nodeValue = Node.null }
            default: break
            }
            nodeValue = Node(i.wrapped)
        }
        else {
            nodeValue = Node.null
        }
        parameters.append(nodeValue)
    }

    public mutating func addParameter<T>(_ structuredData: T?) where T : StructuredDataWrapper {
        let value = (structuredData == nil ? Node.null : Node(structuredData!.wrapped))
        parameters.append(value)
    }
    
    public mutating func addParameter<T>(_ node: T?) throws where T : NodeInitializable {
        let value = (node == nil ? Node.null : try node.makeNode(in: nil))
        addParameter(value)
    }
    
    public mutating func addParameters<T>(_ params: T?...) throws where T : NodeInitializable {
        for parameter in params { try self.addParameter(parameter) }
    }
    
    public mutating func clearParameters() {
        parameters = []
    }
}

// Allow the query to be used as a filter on a Query
extension Query {
    public func filter(_ rawQuery : RawQuery) throws -> Query<E> {
        return try self.filter(raw: rawQuery.query, rawQuery.parameters)
    }
}

/// Allow the query to be executed on an Executor (ie Database and Connection)
extension Executor {
    @discardableResult
    // Executes the given RawQuery
    public func query(_ rawQuery: RawQuery) throws -> Node {
        return try self.raw(rawQuery.query, rawQuery.parameters)
    }
}

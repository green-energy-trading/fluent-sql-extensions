//
//  Preparation.swift
//  FluentSQLExtensions
//
//  Created by David Monagle on 16/11/16.
//
//

import Fluent
import Foundation

/// Base Preparation Class for loading SQL Files or Directories

public protocol GeoPostgreSQLPreparation : Preparation {
}

extension GeoPostgreSQLPreparation {
}

extension Database {
    public func loadSQLFrom(filePath: String) throws {
        try self.transaction() {
            connection in
            try connection.loadSQLFrom(filePath: filePath)
        }
    }
}

extension Executor {
    public func loadSQLFrom(filePath: String) throws {
        if let functionsSQL = try? String(contentsOfFile: filePath, encoding: .utf8) {
            do {
                try self.raw(functionsSQL)
            }
            catch (let error) {
                print("Failed to load file: \(filePath)")
                throw(error)
            }
        }
    }
    
    public func loadSQLFrom(directory: String) throws {
        let fileManager = FileManager()
        do {
            let files = try fileManager.contentsOfDirectory(atPath: directory)
            // TODO: This should probably throw an error if we got this far without realising it's not a postgres connection.
            for file in files {
                if (file.hasSuffix(".sql")) {
                    let filePath = [directory, file].joined(separator: "/")
                    try self.loadSQLFrom(filePath: filePath)
                }
            }
        }
        catch (let error) {
            print("Failed to open directory: \(directory)")
            print(error)
        }
    }
}

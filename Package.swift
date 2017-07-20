// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "FluentSQLExtensions",
    targets: [
        Target(name: "FluentSQLExtensions"),
        Target(name: "FluentPostgreSQLExtensions", dependencies: ["FluentSQLExtensions"]),
    ],
    dependencies: [
        .Package(url: "https://github.com/vapor/fluent.git", majorVersion: 2),
    ]
)

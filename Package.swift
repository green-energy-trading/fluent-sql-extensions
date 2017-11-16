// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "FluentSQLExtensions",
    products: [
        .library(name: "FluentSQLExtensions", targets: ["FluentSQLExtensions", "FluentPostgreSQLExtensions"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/fluent.git", from: Version(2, 0, 0)),
    ],
    targets: [
        .target(name: "FluentSQLExtensions", dependencies: ["Fluent"]),
        .target(name: "FluentPostgreSQLExtensions", dependencies: ["FluentSQLExtensions"]),
    ]
)

package.swiftLanguageVersions = [3, 4]

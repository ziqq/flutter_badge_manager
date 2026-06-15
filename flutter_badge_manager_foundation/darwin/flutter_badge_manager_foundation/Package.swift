// swift-tools-version: 5.9

// Copyright 2025 Anton Ustinoff
// Use of this source code is governed by an MIT license that can be
// found in the LICENSE file.

import Foundation
import PackageDescription

let flutterFrameworkPath = "../FlutterFramework"
let hasFlutterFramework = FileManager.default.fileExists(
  atPath: "\(flutterFrameworkPath)/Package.swift"
)

let packageDependencies: [Package.Dependency] = hasFlutterFramework
  ? [
      .package(name: "FlutterFramework", path: flutterFrameworkPath)
    ]
  : []

let targetDependencies: [Target.Dependency] = hasFlutterFramework
  ? [
      .product(name: "FlutterFramework", package: "FlutterFramework")
    ]
  : []

let excludedSources = hasFlutterFramework
  ? ["SwiftPMShims.swift"]
  : ["FlutterBadgeManagerPlugin.g.swift"]

let package = Package(
  name: "flutter_badge_manager_foundation",
  platforms: [
    .iOS("13.0"),
    .macOS("10.15"),
  ],
  products: [
    .library(name: "flutter-badge-manager-foundation", targets: ["flutter_badge_manager_foundation"])
  ],
  dependencies: packageDependencies,
  targets: [
    .target(
      name: "flutter_badge_manager_foundation",
      dependencies: targetDependencies,
      exclude: excludedSources,
      resources: [
        .process("Resources")
      ]
    ),
    .testTarget(
      name: "flutter_badge_manager_foundationTests",
      dependencies: ["flutter_badge_manager_foundation"]
    )
  ]
)
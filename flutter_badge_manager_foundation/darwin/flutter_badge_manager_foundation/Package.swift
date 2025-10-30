// swift-tools-version: 5.9

// Copyright 2025 Anton Ustinoff
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import PackageDescription

let package = Package(
  name: "flutter_badge_manager_foundation",
  platforms: [
    .iOS("13.0"),
    .macOS("10.15"),
  ],
  products: [
    .library(name: "flutter-badge-manager-foundation", targets: ["flutter_badge_manager_foundation"])
  ],
  dependencies: [],
  targets: [
    .target(
      name: "flutter_badge_manager_foundation",
      dependencies: [],
      resources: [
        .process("Resources")
      ]
    )
  ]
)
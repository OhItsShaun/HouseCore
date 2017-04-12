// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "HouseCore",
    dependencies: [
        .Package(url: "https://github.com/OhItsShaun/Archivable.git", majorVersion: 1),
        .Package(url: "https://github.com/OhItsShaun/Random.git", majorVersion: 1),
        .Package(url: "https://github.com/OhItsShaun/Time.git", majorVersion: 1),
        .Package(url: "https://github.com/OhItsShaun/Shell.git", majorVersion: 1),
        .Package(url: "https://github.com/OhItsShaun/DataStructures.git", majorVersion: 1),
        .Package(url: "https://github.com/IBM-Swift/BlueSocket.git", majorVersion: 0, minor: 12),
    ]
)

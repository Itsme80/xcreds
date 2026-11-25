# Building XCreds

Install Xcode on the Mac and open `XCreds.xcodeproj`.
Select the `XCreds` scheme and configure a signing team for the targets you intend to build.
You can also build from the repository root:

```sh
xcodebuild -resolvePackageDependencies -project XCreds.xcodeproj -scheme XCreds
xcodebuild -project XCreds.xcodeproj -scheme XCreds build
```

The project includes the helper source files directly. Their source is
[the terjekv/xcreds public-source build commit](https://github.com/terjekv/xcreds/commit/897339e1db9156da769a2e4c36a0ee655d15b494).
Xcode fetches OIDCLite and Swift Argument Parser through Swift Package Manager.
This build omits the Twocanoes licensing framework, license check-ins, and framework-based update checks.

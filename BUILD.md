# Building XCreds

## Standard build with AutoFill

Install Xcode on the Mac and open `XCreds.xcodeproj`.
Select the `XCreds` scheme and configure a signing team for the targets you intend to build.
You can also build from the repository root:

```sh
xcodebuild -resolvePackageDependencies -project XCreds.xcodeproj -scheme XCreds
xcodebuild -project XCreds.xcodeproj -scheme XCreds build
```

## Personal Team build without AutoFill

In Xcode, sign in under **Settings > Accounts** with the Apple Account that owns
your Personal Team, then use **Manage Certificates** to create an Apple Development
certificate if you do not have one. Run this from the repository root using your
10-character Team ID:

```sh
./scripts/build-personal-team.sh YOUR_TEAM_ID
```

This builds the app and login plug-in with the AutoFill host and extension omitted.
The script uses a temporary copy and writes the signed app to
`build/PersonalTeam/Build/Products/Debug/XCreds.app`. The standard Xcode project
continues to build with AutoFill.

## Dependencies

The project includes the helper source files directly. Their source is
[the terjekv/xcreds public-source build commit](https://github.com/terjekv/xcreds/commit/897339e1db9156da769a2e4c36a0ee655d15b494).
Xcode fetches OIDCLite and Swift Argument Parser through Swift Package Manager.
This build omits the Twocanoes licensing framework, license check-ins, and framework-based update checks.

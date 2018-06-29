CHANGELOG for Android-SDK cookbook
==================================

v2.0.0 (2018-06-29)
-------------------

This is a nearly total re-write of the cookbook, moving to lightweight resources to manage:
- SDK tools/sdk seed install
- SDK components
- NDK installs
- Android emulators

NDK installs are entirely separate for the others. You do not need the SDK to install an NDK and vice versa.

Emulators rely that the SDK is installed as are the components necessary for the emulator (system-images, platforms).

SDK components are the same items of the SKD you install via the Android STudio UI.

The SDK resource actually refers to the SDK tools zip used to give you the core tooling/binaries of the SDK. It is required to have this first to manage SDK components (since they're managed via the sdkmanager binary included in the SDK's `tools/bin` folder.)

v0.2.0 (2015-10-17)
-------------------

- Integrate by default with Android SDK 24.4.0 (October 2015)
- Add the `java_from_system` option to skip java cookbook dependency (disabled by default)
- Add the `set_environment_variables` option to automatically set related environment variables
  in user shell (enabled by default)
- Add the `with_symlink` option to use ark's friendly symlink feature (enabled by default)
- Deploy scripts for waiting on Emulator startup [GH-16]
- Deploy scripts for non-interactive SDK setup/updates [GH-13]
- Add Rubocop checks [GH-7]
- Optionally install Maven Android SDK Deployer [GH-14]

v0.1.1 (2014-04-01)
-------------------

- No code changes compared to v0.1.0
- Fixed community packaging (Stove included ~ backup files in v0.1.0 tarball)
- Minor fixes (typo and lint errors)

v0.1.0 (2014-03-31)
-------------------

- Accept or Reject some SDK licenses with expect [GH-11]
- Add a basic idempotent guard [GH-10]
- Accept all SDK licenses with expect [GH-3]
- Support for Ubuntu 12.04+ (32bit and 64bit) [GH-1]
- Integrate by default with Android SDK 22.6.2

v0.0.0 (2013-08-08)
-------------------

*First Draft*

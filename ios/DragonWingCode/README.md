# DragonWing Code for iOS

DragonWing Code is an independent, offline-first code workbench for iPhone and iPad, inspired by the Visual Studio Code workflow. It is not an official Microsoft product or a complete port of VS Code Desktop.

## Implemented in this build

- Native SwiftUI workbench with Editor, Files, Terminal, Extensions and Themes tabs
- Monaco Editor bundled into the app by CI, so the editor does not need a CDN at runtime
- Local workspace storage in the app's Documents directory
- Import source files through the iOS Files picker and save local edits
- Four editor themes: Midnight, Graphite, Light and Nord
- Sandboxed local command console with a deliberately limited command set
- Open VSX search and VSIX package download when online
- Generated iOS app icon included in the build

## iOS platform limits — important

iOS apps run in a sandbox. The Terminal tab is a restricted command console, not a general Unix shell, and it does not provide root access or arbitrary process execution. Open VSX packages can be searched and downloaded, but a compatible VS Code extension host and activation runtime are not implemented yet. Many desktop extensions require Node.js native modules, desktop APIs or unrestricted process access and cannot run unchanged on iOS.

The current app does not yet include a full Git client, debugger, language-server suite, unrestricted shell, remote-device protocol, or complete VS Code extension compatibility. Remote connections to a user-owned laptop or UNO Q remain future work.

## Offline behavior

Editing, local file storage, themes and the restricted console are designed to work offline. Open VSX search and package downloads require an Internet connection. Monaco's editor assets are fetched during CI and bundled in the IPA, not loaded from a CDN at runtime.

## Next runtime phase

The engineering plan for progressive VS Code extension compatibility (including Error Lens-style diagnostics) and the DragonWing Translation Kernel (DTK) is documented in [ARCHITECTURE-NEXT.md](ARCHITECTURE-NEXT.md). These are planned capabilities, not features in the current IPA. A normal iOS app cannot boot a replacement Linux kernel or run arbitrary Debian ELF binaries, so the DTK will begin as a sandboxed Linux-like userspace and must pass real-device tests before any Debian compatibility claim.

## Build

The GitHub Actions workflow installs XcodeGen, downloads Monaco Editor assets, generates the app icon, builds the iOS device app without signing, packages an unsigned IPA, and builds the simulator app.

To install on a physical iPhone, sign the app with your own Apple development identity. An unsigned IPA is not directly installable by itself. LiveContainer compatibility must be tested on-device and is not guaranteed by a successful Xcode build.

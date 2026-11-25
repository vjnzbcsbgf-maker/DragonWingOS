# DragonWing Code for iOS

DragonWing Code is the first native iPhone/iPad code-editor foundation in DragonWingOS.

## Current scope
- Native SwiftUI interface with a dark, editor-focused layout
- Local text/source editing
- Open files through the iOS document picker
- Export edited files through the iOS share/document exporter
- iPhone and iPad target support

## Important status
This is **not a complete port of the Visual Studio Code desktop workbench**. VS Code Desktop is built on Electron, Node.js and native services that cannot simply be carried over to iOS. This initial implementation is a native mobile editor foundation. It does not yet include the VS Code extension host, integrated shell, debugger, language servers, full workspace/Git support, or Monaco.

The project deliberately uses the DragonWing Code name and does not present itself as an official Microsoft product.

## Build
The project uses XcodeGen.

```sh
brew install xcodegen
cd ios/DragonWingCode
xcodegen generate
xcodebuild -project DragonWingCode.xcodeproj -scheme DragonWingCode -sdk iphonesimulator -configuration Debug CODE_SIGNING_ALLOWED=NO
```

To install on a physical iPhone, build/sign with Xcode using your own Apple development team. An unsigned build artifact is not installable by itself.

# DragonWing Code Niche

A separate native iOS workbench target, developed alongside the original DragonWing Code app.

## Current milestone

This is the Niche foundation, not a complete VS Code port. It currently provides:
- Native SwiftUI workbench layout with activity bar, explorer panel, editor tab and status bar.
- Editable source buffer.
- iOS document picker import and file export.
- Basic command palette.
- Search within the open buffer.
- Separate bundle identifier: `dev.dragonwing.code.niche`.

## Not implemented yet

The Code OSS workbench, Monaco integration, VS Code extension host/API, Git engine, terminal runtime, language servers, debugger and DTK are not part of this milestone. UI elements that are placeholders are labeled as such.

## Upstream strategy

The planned upstream is Microsoft's MIT-licensed Code - OSS repository, not the proprietary Visual Studio Code distribution. The upstream repository currently declares Electron as its native runtime, so an iOS build requires replacing desktop-only services and adapting browser-compatible workbench components. See [Code - OSS](https://github.com/microsoft/vscode) and [VS Code for the Web architecture and limitations](https://code.visualstudio.com/docs/remote/vscode-web).

Keep the original DragonWing Code target untouched. Niche has its own XcodeGen project and CI workflow.

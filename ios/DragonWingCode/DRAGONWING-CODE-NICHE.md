# DragonWing Code Niche

DragonWing Code Niche is the ambitious Code-OSS-derived iOS edition of DragonWing Code. It is a separate product target, not a claim that desktop VS Code can be copied unchanged onto iOS.

## Product objective

Preserve the recognizable VS Code workbench and as much upstream Code-OSS behavior and source as can legally and technically run on iOS. The target is feature parity by subsystem, with an explicit compatibility matrix.

## Upstream and licensing

- Base the work on Microsoft's Code - OSS source, not proprietary Visual Studio Code distribution assets or Microsoft-only services.
- Pin an upstream Code-OSS commit and record it in `UPSTREAM.md` before importing source.
- Preserve upstream LICENSE, ThirdPartyNotices, copyright headers and all applicable notices.
- Keep DragonWing-specific code in a separate layer so upstream changes can be rebased and audited.
- Do not copy marketplace-only assets, proprietary services, or code without verifying its license.

## Architecture

### Workbench

Port the workbench UI concepts and interaction model: activity bar, side bar, explorer, search, source control view, run/debug view, extensions view, editor groups, tabs, breadcrumbs, status bar, panels, settings and keyboard shortcuts. On iPhone, use adaptive layouts and touch-safe hit targets while retaining desktop-like behavior when a keyboard or pointer is attached.

### Editor

Use upstream Monaco as the initial editor engine, then align its version and behavior with the pinned Code-OSS revision. Preserve model/URI semantics, language configuration, decorations, diagnostics, diff editor, minimap where practical, folding, multi-cursor, find/replace and keybindings.

### Extension host

Implement a VS Code API compatibility layer in stages. Start with declarative contributions (themes, grammars, snippets, menus, commands, keybindings, decorations and diagnostics), then language providers and a sandboxed JavaScript extension host. Desktop extensions requiring Node native addons, subprocesses, Electron APIs, debugger processes or unrestricted filesystem access are not automatically portable. Maintain an API support matrix and per-extension capability manifest.

### Runtime and terminal

DragonWing Translation Kernel (DTK) is a sandboxed userspace compatibility runtime, not a replacement iOS kernel. Its first implementation is a virtual filesystem and command runtime. A Debian ARM64 userspace is a later research track and may require a compatible interpreter/translator; ordinary iOS apps cannot boot Linux or execute arbitrary ELF binaries directly. Never label a shell as Debian until real Debian userland binaries have been executed and tested on-device.

### Platform adapters

Replace Electron/main-process services with native iOS adapters for documents, file coordination, settings, window lifecycle, notifications, networking and secure credential storage. Every adapter must declare where semantics differ from desktop VS Code.

## Feature parity matrix

| Subsystem | Niche target | Port strategy |
|---|---|---|
| Workbench UI | High | Recreate/adapt Code-OSS workbench with iOS layout |
| Monaco editor | High | Upstream Monaco bundle, offline assets |
| Explorer/files | High | iOS document picker + app workspace |
| Search | High | Workspace index in sandbox |
| Git/source control | Medium-high | Portable Git library/runtime after validation |
| Extensions | Progressive | VS Code API shim + capability sandbox |
| Error Lens | High priority | Diagnostics mapped to Monaco decorations/widgets |
| Gemini/Antigravity | Conditional | Provider integration; audit exact extension/API requirements |
| Debugging | Conditional | DAP client only where a supported debug adapter exists |
| Terminal | Progressive | DTK userspace; no root or unrestricted shell |
| Tasks/build | Conditional | Sandboxed task runners and supported toolchains |
| Remote SSH | Later | Explicit user-configured remote protocol and credentials |

## Delivery phases

1. **Niche foundation:** create a distinct app target, branding, upstream pin, legal notices and compatibility tests.
2. **Workbench parity:** activity bar, explorer, search, tabs/groups, panels, settings and keyboard shortcuts.
3. **Editor parity:** Monaco alignment, diff editor, diagnostics, symbols, formatting, completion and code actions.
4. **Extension compatibility:** VS Code API shim, extension manifest parser, safe VSIX extraction, permissions, declarative contributions and selected extension host APIs.
5. **Developer tools:** Git, task runner, debugger protocol, language servers and DTK terminal as each passes iOS feasibility tests.
6. **Upstream maintenance:** automated upstream diff review, dependency/license audit and regression suite.

## Definition of done

- A pinned upstream Code-OSS commit and reproducible import/update process exist.
- The Niche target builds independently of the original DragonWing Code target.
- Every claimed feature has an automated test and a real-device test.
- The app works offline for bundled editor/workbench functionality.
- Unsupported APIs and extensions fail with clear compatibility reasons rather than silent partial execution.
- No claim of total VS Code parity is made until the compatibility matrix proves it.
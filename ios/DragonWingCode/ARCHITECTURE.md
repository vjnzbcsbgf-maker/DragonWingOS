# DragonWing Code — Offline-first architecture

## Product goal

DragonWing Code is an independent iOS code workbench inspired by the Visual Studio Code workflow. It is not an official Microsoft product and must not claim binary or feature parity with desktop VS Code.

The iPhone is the primary runtime. A connection to a laptop or UNO Q is optional and must never be required to open, edit, save, or browse a local project.

## iOS constraints

iOS apps run inside an application sandbox. They cannot expose an unrestricted POSIX shell, install arbitrary native executables, or load desktop VS Code extensions that depend on Node.js native modules, desktop APIs, or unrestricted filesystem access. Therefore "local terminal" means a sandboxed command environment with a documented command set and runtimes that are explicitly bundled for iOS; it is not a root shell.

## Proposed architecture

- **Native SwiftUI shell:** navigation, tabs, file picker, settings, themes, permissions and device connections.
- **Editor engine:** bundle Monaco Editor assets locally in the app. No CDN dependency at runtime. Use language workers packaged with the app and keep a native fallback editor for unsupported cases.
- **Workspace storage:** Swift file/document APIs and security-scoped bookmarks for user-selected folders. All reads and writes stay inside granted locations.
- **Terminal panel:** bundle xterm.js for terminal UI and connect it to a restricted local command/runtime bridge. Clearly label unsupported commands; never pretend it is a full iOS shell.
- **Language support:** local syntax highlighting and language services where feasible. Add formatters, linters and LSP-like services only when their runtime and licensing are compatible with iOS.
- **Extensions:** discover extensions from Open VSX; download and inspect VSIX packages; initially support a curated compatibility allowlist of web extensions and language assets. Reject desktop-only extensions, native binaries, and unsupported activation APIs. Extension installation must be visible and removable.
- **Themes:** support editor/workbench themes locally, including import/export where safe.
- **Optional remote targets:** explicit user-configured connections to a laptop or UNO Q for remote execution, Git operations, or heavier language servers. Local editing must continue if disconnected.

## Delivery phases

1. **Offline workbench:** app icon, file/workspace navigation, multi-tab editor, local persistence, themes, search and settings.
2. **Editor engine:** locally bundled Monaco, syntax workers and diagnostics for selected languages.
3. **Local terminal:** xterm.js plus a restricted command environment and bundled interpreters where technically viable.
4. **Extensions:** Open VSX catalogue, VSIX installation, compatibility checks and web-extension runtime for supported extensions.
5. **Developer tools:** Git integration, formatters, snippets, debugger adapters and project templates.
6. **Optional device links:** secure opt-in connections to user-owned devices; no cloud dependency.

## Acceptance criteria

- Core editing, opening, saving, themes and file navigation work in airplane mode.
- No runtime CDN, analytics, telemetry, or mandatory account.
- The app clearly distinguishes supported local commands/extensions from unsupported desktop-only features.
- No downloaded extension executes with unrestricted access to the iOS filesystem.
- Every release is built and tested with the repository's iOS CI workflow; LiveContainer compatibility is tested separately and never assumed from a successful Xcode build.

# DragonWing Code — Runtime Architecture (Phase 2)

This document defines the next implementation boundary. It is an engineering plan, not a claim that these features are already shipped.

## 1. Extension compatibility

### Target
Build a safe, progressive VS Code-compatible extension layer rather than pretending that every desktop VSIX can run unchanged on iOS.

### Compatibility tiers
1. Editor contributions: themes, language configuration, snippets, decorations and diagnostics.
2. Workbench contributions: commands, keybindings, menus, status items and settings.
3. Language features: diagnostics, completion, hover, symbols, formatting and code actions through a constrained provider API.
4. External services: extensions that require network APIs (for example Gemini-backed assistants) can work only when their authentication, API terms, network access and provider APIs are supported.
5. Unsupported without a separate runtime: extensions requiring native Node modules, arbitrary subprocesses, desktop UI APIs, debugger backends or unrestricted filesystem access.

### Error Lens path
Error Lens-style inline diagnostics are a priority because they can be rendered by Monaco without loading an entire desktop extension host:
- Define a DragonWing diagnostic model (URI, range, severity, message, source).
- Map diagnostics to Monaco markers.
- Render the message inline using Monaco content widgets/decorations.
- Add severity filters and a toggle in the app.
- Keep diagnostic providers separate from rendering so built-in analyzers and future compatible extensions share one interface.

### Extension security
VSIX files are untrusted input. Inspect package metadata, enforce size limits, reject path traversal during extraction, and run supported extension JavaScript in an isolated context with explicit capabilities. Never execute a VSIX merely because it was downloaded. Network access and file access must be permission-gated.

### Antigravity / Gemini
Antigravity compatibility cannot be inferred from its name alone. Gemini integrations may depend on Google authentication, proprietary service APIs, VS Code extension APIs, and/or native components. The compatibility layer should first support generic web/API-backed assistant providers through user-supplied credentials and explicit network permission. Do not claim native Antigravity compatibility until its actual package and API requirements have been audited and tested.

## 2. DragonWing Translation Kernel (DTK)

### Goal
Replace the current demo command console with a deterministic, offline, Linux-like userspace runtime implemented inside the iOS app sandbox.

### Important platform boundary
A normal iOS app cannot boot or install a replacement Linux kernel on the iPhone, gain root, use unrestricted chroot/ptrace, or launch arbitrary downloaded ELF executables. The DTK therefore cannot honestly be described as a full native Linux kernel.

### Proposed architecture
- DTK Core: Swift syscall/VFS façade, path normalization, permissions, process/session model and virtual environment variables.
- VFS: app-container-backed filesystem with /home, /tmp, /etc and /usr virtual roots. All paths must remain inside the app container.
- Command runtime: built-in offline commands first; later, a vetted interpreter/runtime for selected languages where iOS permits it.
- Debian profile: Debian-like filesystem layout, package metadata and familiar shell UX. A Debian root filesystem can be offered only if its binaries can actually execute under the chosen iOS-safe runtime; otherwise label it a Debian-compatible profile, not Debian itself.
- Syscall compatibility: implement a documented subset with explicit ENOSYS-style responses for unsupported calls. Do not silently pretend unsupported Linux syscalls succeeded.
- Performance: avoid emulating hardware unnecessarily; use native Swift for VFS and command dispatch, cache parsed metadata, and keep the editor/runtime isolated.
- Security: no root claim, no unrestricted network, no executing arbitrary package scripts, and no escape from the app sandbox.

### Milestones
1. Replace the existing switch-based console with a testable virtual filesystem and command registry.
2. Add shell parsing, pipes/redirection only after a safe parser exists.
3. Add offline core utilities and environment variables.
4. Add a constrained language runtime (for example Python or JavaScript) only after validating iOS execution and package provenance.
5. Evaluate an ARM64 Linux userspace compatibility approach on real devices. A full Debian userspace is a separate feasibility gate.

## 3. Acceptance tests
- Diagnostics appear at the correct line/column and clear when the source changes.
- Extension permissions are denied by default and can be revoked.
- Malformed VSIX archives cannot write outside the extension directory.
- pwd, ls, cat, mkdir, touch, cp, mv, rm and shell parsing operate only inside the virtual root.
- Offline terminal startup and command execution require no network.
- Unsupported syscalls/commands report explicit errors.
- All runtime behavior is tested on a physical iPhone; simulator build success alone is not acceptance.
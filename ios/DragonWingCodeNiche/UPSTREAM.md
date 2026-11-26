# Code - OSS upstream tracking

DragonWing Code Niche targets the open-source Visual Studio Code source tree (Code - OSS):
https://github.com/microsoft/vscode

## Pinned upstream revision

- Repository: https://github.com/microsoft/vscode
- Ref at pin time: `main`
- Commit: `a0913d44a9bfd44328303300cd8a668e6967de76`
- Commit URL: https://github.com/microsoft/vscode/commit/a0913d44a9bfd44328303300cd8a668e6967de76

This is a source pin for compatibility analysis and future selective porting. It does **not** mean the Code - OSS workbench has already been imported or that this iOS app is currently built from the complete upstream tree.

## Licensing and provenance

Code - OSS is distributed under the MIT license. Any upstream source imported into this repository must retain its copyright notices and license text. Third-party dependencies must retain their own notices and license obligations. Do not import Visual Studio Code Marketplace proprietary components, Microsoft-only services, or assets unless their licenses explicitly permit redistribution.

## Porting policy

- Keep upstream source in a clearly separated directory and preserve provenance.
- Pin every imported upstream revision; never track a moving branch in release builds.
- Port platform services behind iOS adapters rather than pretending Electron APIs exist on iOS.
- Record every unsupported or behaviorally different API in the compatibility matrix.
- Do not claim a subsystem is ported until it is implemented and tested on a physical iPhone.

## Current implementation status

- Monaco Editor: integrated as a locally bundled WebKit editor engine; CI vendors the pinned npm package version.
- Native iOS shell: SwiftUI app target.
- Code - OSS workbench: not yet imported.
- VS Code extension host / Node runtime: not yet implemented.
- Git, DAP debugging, tasks and terminal: not yet implemented in Niche.

## Next port milestones

1. Import and audit the upstream workbench source and its dependency/licensing graph.
2. Port the workbench contribution system and service registry behind iOS adapters.
3. Add multi-file workspace, editor tabs/groups, command registry, keybindings and settings.
4. Align Monaco version and configuration with the pinned upstream revision.
5. Implement a capability-scoped extension compatibility host; reject unsupported native modules and subprocess APIs clearly.
6. Add Git, diagnostics/language services, DAP and a constrained terminal only after device-level feasibility tests.

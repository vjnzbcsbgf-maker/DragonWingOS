import SwiftUI
import UniformTypeIdentifiers

struct WorkspaceView: View {
    @EnvironmentObject private var themes: ThemeStore
    @State private var selectedTab = 0
    @State private var source = """
// DragonWing Code — offline-first mobile workbench
function hello(name) {
  return `Hello, ${name}!`;
}
console.log(hello("iPhone"));
"""
    @State private var fileName = "untitled.js"
    @State private var files: [URL] = []
    @State private var showingImporter = false
    @State private var status = "Ready"
    private var root: URL { FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] }
    private var document: CodeDocument { CodeDocument(text: source) }

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack { editorScreen }
                .tabItem { Label("Editor", systemImage: "chevron.left.forwardslash.chevron.right") }.tag(0)
            NavigationStack { filesScreen }
                .tabItem { Label("Files", systemImage: "folder") }.tag(1)
            NavigationStack { TerminalView() }
                .tabItem { Label("Terminal", systemImage: "terminal") }.tag(2)
            NavigationStack { ExtensionsView() }
                .tabItem { Label("Extensions", systemImage: "puzzlepiece.extension") }.tag(3)
            NavigationStack { settingsScreen }
                .tabItem { Label("Themes", systemImage: "paintpalette") }.tag(4)
        }
        .tint(themes.selected.accent)
        .preferredColorScheme(themes.selected.isLight ? .light : .dark)
        .onAppear(perform: refreshFiles)
    }

    private var editorScreen: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "chevron.left.forwardslash.chevron.right").foregroundStyle(.cyan)
                Text(fileName).font(.system(.subheadline, design: .monospaced))
                Spacer()
                Text("LOCAL").font(.caption2.bold()).foregroundStyle(.green)
                Button { saveCurrent() } label: { Image(systemName: "square.and.arrow.down") }
                    .accessibilityLabel("Save file")
            }.padding(.horizontal).padding(.vertical, 10)
            EditorWebView(text: $source, theme: themes.selected, language: languageForFile(fileName))
                .background(themes.selected.background)
            HStack {
                Text(status)
                Spacer()
                Text("\(source.split(separator: "\n", omittingEmptySubsequences: false).count) lines")
            }.font(.caption2).foregroundStyle(.secondary).padding(.horizontal).padding(.vertical, 7)
        }
        .navigationTitle("DragonWing Code").navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button { showingImporter = true } label: { Image(systemName: "folder.badge.plus") }
                Button { saveCurrent() } label: { Image(systemName: "checkmark") }
            }
        }
        .fileImporter(isPresented: $showingImporter, allowedContentTypes: [.plainText, .sourceCode, .json, .xml], allowsMultipleSelection: false) { result in
            guard case .success(let urls) = result, let url = urls.first else { return }
            let access = url.startAccessingSecurityScopedResource()
            defer { if access { url.stopAccessingSecurityScopedResource() } }
            do {
                source = try String(contentsOf: url, encoding: .utf8)
                fileName = url.lastPathComponent
                status = "Opened"
            } catch { status = "Open failed" }
        }
    }

    private var filesScreen: some View {
        List {
            Section("On My iPhone · DragonWing Code") {
                if files.isEmpty { Text("No saved files yet. Save a file from the editor or create one below.").foregroundStyle(.secondary) }
                ForEach(files, id: \.path) { url in
                    Button {
                        if let value = try? String(contentsOf: url, encoding: .utf8) {
                            source = value; fileName = url.lastPathComponent; selectedTab = 0; status = "Opened from workspace"
                        }
                    } label: {
                        Label(url.lastPathComponent, systemImage: "doc.text").foregroundStyle(.primary)
                    }
                }
            }
            Section {
                Button { createFile() } label: { Label("New untitled file", systemImage: "plus") }
                Button { showingImporter = true } label: { Label("Import from Files", systemImage: "square.and.arrow.down") }
            }
        }.navigationTitle("Workspace").toolbar { Button(action: refreshFiles) { Image(systemName: "arrow.clockwise") } }
    }

    private var settingsScreen: some View {
        Form {
            Section("Editor theme") {
                ForEach(EditorTheme.allCases) { theme in
                    Button {
                        themes.selected = theme
                    } label: {
                        HStack {
                            Text(theme.rawValue).foregroundStyle(.primary)
                            Spacer()
                            if themes.selected == theme { Image(systemName: "checkmark").foregroundStyle(.tint) }
                        }
                    }
                }
            }
            Section("Runtime") {
                Label("Offline editing and file storage", systemImage: "iphone")
                Label("Sandboxed local command console", systemImage: "terminal")
                Label("Open VSX catalogue requires Internet", systemImage: "network")
                Label("Remote device support: planned", systemImage: "laptopcomputer")
            }
            Section("Compatibility") {
                Text("DragonWing Code is an independent iOS editor. It does not run arbitrary desktop VS Code extensions or provide an unrestricted Unix shell. VSIX packages can currently be downloaded for inspection; activation is not implemented.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
        }.navigationTitle("Settings & Themes")
    }

    private func saveCurrent() {
        let clean = fileName.isEmpty ? "untitled.txt" : fileName
        let safe = clean.replacingOccurrences(of: "/", with: "_")
        do {
            try source.write(to: root.appendingPathComponent(safe), atomically: true, encoding: .utf8)
            fileName = safe; status = "Saved locally"; refreshFiles()
        } catch { status = "Save failed: \(error.localizedDescription)" }
    }
    private func createFile() {
        fileName = "untitled-\(files.count + 1).js"; source = "// New file\n"; saveCurrent(); selectedTab = 0
    }
    private func refreshFiles() {
        files = ((try? FileManager.default.contentsOfDirectory(at: root, includingPropertiesForKeys: nil)) ?? [])
            .filter { $0.pathExtension.lowercased() != "vsix" }
            .sorted { $0.lastPathComponent.localizedCaseInsensitiveCompare($1.lastPathComponent) == .orderedAscending }
    }
    private func languageForFile(_ name: String) -> String {
        switch URL(fileURLWithPath: name).pathExtension.lowercased() {
        case "js", "mjs": return "javascript"
        case "ts": return "typescript"
        case "json": return "json"
        case "html", "htm": return "html"
        case "css": return "css"
        case "py": return "python"
        case "md": return "markdown"
        case "xml", "svg": return "xml"
        case "swift": return "swift"
        default: return "plaintext"
        }
    }
}

struct CodeDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.plainText, .sourceCode] }
    var text: String
    init(text: String = "") { self.text = text }
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents, let value = String(data: data, encoding: .utf8) else {
            throw CocoaError(.fileReadCorruptFile)
        }
        text = value
    }
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: Data(text.utf8))
    }
}

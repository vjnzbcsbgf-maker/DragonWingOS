import SwiftUI
import UniformTypeIdentifiers

private enum NichePanel: String, CaseIterable, Identifiable {
    case explorer = "Explorer"
    case search = "Search"
    case source = "Source Control"
    case extensions = "Extensions"
    case settings = "Settings"

    var id: String { rawValue }
    var symbol: String {
        switch self {
        case .explorer: return "folder"
        case .search: return "magnifyingglass"
        case .source: return "point.3.connected.trianglepath.dotted"
        case .extensions: return "square.grid.2x2"
        case .settings: return "gearshape"
        }
    }
}

struct NicheWorkbenchView: View {
    @State private var selectedPanel: NichePanel = .explorer
    @State private var fileName = "Welcome.swift"
    @State private var source = """
// DragonWing Code Niche
// Native iOS workbench foundation

import SwiftUI

struct HelloWorld: View {
    var body: some View {
        Text("Hello, Niche!")
    }
}
"""
    @State private var showImporter = false
    @State private var showExporter = false
    @State private var showCommandPalette = false
    @State private var query = ""
    @State private var status = "Ready"

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                header
                HStack(spacing: 0) {
                    activityBar
                    Divider().overlay(Color.white.opacity(0.08))
                    sidePanel
                    Divider().overlay(Color.white.opacity(0.08))
                    editor
                }
                statusBar
            }
            .background(Color(red: 0.075, green: 0.085, blue: 0.11))
            .toolbar(.hidden, for: .navigationBar)
            .fileImporter(isPresented: $showImporter, allowedContentTypes: [.item], allowsMultipleSelection: false) { result in
                do {
                    guard let url = try result.get().first else { return }
                    let access = url.startAccessingSecurityScopedResource()
                    defer { if access { url.stopAccessingSecurityScopedResource() } }
                    source = try String(contentsOf: url, encoding: .utf8)
                    fileName = url.lastPathComponent
                    status = "Opened \(fileName)"
                } catch { status = "Open failed: \(error.localizedDescription)" }
            }
            .fileExporter(isPresented: $showExporter, document: NicheTextDocument(text: source), contentType: .plainText, defaultFilename: fileName) { result in
                status = (try? result.get()) != nil ? "Saved \(fileName)" : "Save failed"
            }
            .sheet(isPresented: $showCommandPalette) {
                NavigationStack {
                    List {
                        Button("Open File…") { showCommandPalette = false; showImporter = true }
                        Button("Save File…") { showCommandPalette = false; showExporter = true }
                        Button("Show Explorer") { selectedPanel = .explorer; showCommandPalette = false }
                        Button("Show Search") { selectedPanel = .search; showCommandPalette = false }
                    }
                    .navigationTitle("Command Palette")
                    .searchable(text: $query, prompt: "Search commands")
                    .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done") { showCommandPalette = false } } }
                }
                .presentationDetents([.medium, .large])
            }
        }
        .tint(Color(red: 0.35, green: 0.68, blue: 0.98))
    }

    private var header: some View {
        HStack(spacing: 12) {
            Image(systemName: "chevron.left.forwardslash.chevron.right")
                .foregroundStyle(.cyan)
            Text("DragonWing Code").font(.headline)
            Text("NICHE").font(.system(size: 9, weight: .bold)).padding(.horizontal, 6).padding(.vertical, 3)
                .background(Color.cyan.opacity(0.15), in: Capsule()).foregroundStyle(.cyan)
            Spacer()
            Button { showCommandPalette = true } label: {
                Image(systemName: "command").padding(8).background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 7))
            }
            Button { showImporter = true } label: { Image(systemName: "folder.badge.plus") }
            Button { showExporter = true } label: { Image(systemName: "square.and.arrow.down") }
        }
        .padding(.horizontal, 14).padding(.vertical, 11)
        .background(Color(red: 0.10, green: 0.115, blue: 0.15))
    }

    private var activityBar: some View {
        VStack(spacing: 22) {
            ForEach(NichePanel.allCases) { panel in
                Button { selectedPanel = panel } label: {
                    Image(systemName: panel.symbol).font(.system(size: 20, weight: .regular))
                        .foregroundStyle(selectedPanel == panel ? .white : .gray)
                        .frame(width: 48, height: 42)
                        .overlay(alignment: .leading) {
                            if selectedPanel == panel { Capsule().fill(Color.cyan).frame(width: 3, height: 28) }
                        }
                }
                .accessibilityLabel(panel.rawValue)
            }
            Spacer()
        }
        .padding(.top, 12).frame(width: 50)
        .background(Color(red: 0.065, green: 0.075, blue: 0.095))
    }

    private var sidePanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(selectedPanel.rawValue.uppercased()).font(.system(size: 10, weight: .bold)).foregroundStyle(.gray)
            if selectedPanel == .explorer {
                Text("DRAGONWING").font(.system(size: 10, weight: .semibold)).foregroundStyle(.gray)
                Label(fileName, systemImage: "swift").font(.system(size: 12)).lineLimit(1)
                    .padding(.leading, 4)
                Text("No workspace folder open").font(.system(size: 11)).foregroundStyle(.secondary)
                Button("Open File…") { showImporter = true }.font(.system(size: 12))
            } else if selectedPanel == .search {
                TextField("Search in file", text: $query).textFieldStyle(.roundedBorder).font(.caption)
                Text(query.isEmpty ? "Type to search this editor." : (source.localizedCaseInsensitiveContains(query) ? "Match found in current file." : "No matches."))
                    .font(.caption).foregroundStyle(.secondary)
            } else {
                Text(panelDescription).font(.caption).foregroundStyle(.secondary)
                if selectedPanel == .extensions {
                    Link("Browse Open VSX", destination: URL(string: "https://open-vsx.org")!)
                }
            }
            Spacer()
        }
        .padding(12).frame(width: 150, alignment: .leading)
        .background(Color(red: 0.085, green: 0.095, blue: 0.12))
    }

    private var panelDescription: String {
        switch selectedPanel {
        case .source: return "Git integration is not connected yet."
        case .extensions: return "Extension host is not available in this build."
        case .settings: return "Workbench settings will live here."
        default: return ""
        }
    }

    private var editor: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: "swift").foregroundStyle(.orange)
                Text(fileName).font(.system(size: 12))
                Spacer()
                Circle().fill(.green).frame(width: 6, height: 6)
            }
            .padding(.horizontal, 12).frame(height: 36)
            .background(Color(red: 0.09, green: 0.10, blue: 0.13))
            TextEditor(text: $source)
                .font(.system(size: 13, weight: .regular, design: .monospaced))
                .scrollContentBackground(.hidden)
                .foregroundStyle(Color(red: 0.82, green: 0.86, blue: 0.91))
                .padding(6)
                .background(Color(red: 0.075, green: 0.085, blue: 0.11))
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var statusBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
            Text(status).lineLimit(1)
            Spacer()
            Text("UTF-8")
            Text("Swift")
        }
        .font(.system(size: 10, weight: .medium))
        .foregroundStyle(.white.opacity(0.9))
        .padding(.horizontal, 10).frame(height: 23)
        .background(Color(red: 0.12, green: 0.32, blue: 0.48))
    }
}

private struct NicheTextDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.plainText, .sourceCode] }
    var text: String
    init(text: String) { self.text = text }
    init(configuration: ReadConfiguration) throws {
        text = String(decoding: configuration.file.regularFileContents ?? Data(), as: UTF8.self)
    }
    func fileWrapper(configuration: WriteConfiguration) throws {
        FileWrapper(regularFileWithContents: Data(text.utf8))
    }
}

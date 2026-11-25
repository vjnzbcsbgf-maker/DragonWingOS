import SwiftUI
import UniformTypeIdentifiers

struct WorkspaceView: View {
    @State private var fileName = "untitled.js"
    @State private var source = """
// DragonWing Code
// A mobile code-workbench prototype for iPhone and iPad.

function hello(name) {
  return `Hello, ${name}!`;
}

console.log(hello("DragonWing"));
"""
    @State private var showingImporter = false
    @State private var showingExporter = false
    @State private var showingAbout = false

    private var document: CodeDocument {
        CodeDocument(text: source)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack(spacing: 8) {
                    Image(systemName: "chevron.left.forwardslash.chevron.right")
                        .foregroundStyle(.cyan)
                    Text(fileName)
                        .font(.system(.subheadline, design: .monospaced))
                        .foregroundStyle(.white)
                    Spacer()
                    Circle().fill(.green).frame(width: 7, height: 7)
                    Text("LOCAL")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 11)
                .background(Color(red: 0.10, green: 0.11, blue: 0.14))

                ZStack(alignment: .topLeading) {
                    Color(red: 0.055, green: 0.065, blue: 0.085)
                    TextEditor(text: $source)
                        .font(.system(size: 14, weight: .regular, design: .monospaced))
                        .scrollContentBackground(.hidden)
                        .foregroundStyle(Color(red: 0.82, green: 0.87, blue: 0.93))
                        .tint(.cyan)
                        .padding(.horizontal, 8)
                        .padding(.top, 8)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }

                HStack {
                    Label("DragonWing Code", systemImage: "bird")
                    Spacer()
                    Text("\(source.split(separator: "\n", omittingEmptySubsequences: false).count) lines")
                        .monospacedDigit()
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background(Color(red: 0.10, green: 0.11, blue: 0.14))
            }
            .navigationTitle("Code")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button { showingImporter = true } label: {
                        Image(systemName: "folder")
                    }
                    .accessibilityLabel("Open file")
                    Button { showingExporter = true } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .accessibilityLabel("Export file")
                    Button { showingAbout = true } label: {
                        Image(systemName: "info.circle")
                    }
                    .accessibilityLabel("About")
                }
            }
            .fileImporter(isPresented: $showingImporter, allowedContentTypes: [.plainText, .sourceCode, .json, .xml], allowsMultipleSelection: false) { result in
                guard case .success(let urls) = result, let url = urls.first else { return }
                let access = url.startAccessingSecurityScopedResource()
                defer { if access { url.stopAccessingSecurityScopedResource() } }
                if let data = try? Data(contentsOf: url), let text = String(data: data, encoding: .utf8) {
                    source = text
                    fileName = url.lastPathComponent
                }
            }
            .fileExporter(isPresented: $showingExporter, document: document, contentType: .plainText, defaultFilename: fileName) { _ in }
            .alert("DragonWing Code", isPresented: $showingAbout) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("A native iOS code-editor foundation. This is not the full Visual Studio Code workbench yet; extensions, integrated terminals and language servers are not included.")
            }
        }
    }
}

struct CodeDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.plainText, .sourceCode] }
    var text: String

    init(text: String = "") { self.text = text }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let value = String(data: data, encoding: .utf8) else {
            throw CocoaError(.fileReadCorruptFile)
        }
        text = value
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: Data(text.utf8))
    }
}

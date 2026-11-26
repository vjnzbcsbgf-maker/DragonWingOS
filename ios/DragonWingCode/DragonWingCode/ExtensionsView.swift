import SwiftUI

struct OpenVSXExtension: Identifiable, Decodable {
    var namespace: String
    var name: String
    var displayName: String?
    var version: String?
    var downloadCount: Int?
    var id: String { namespace + "." + name }
    enum CodingKeys: String, CodingKey {
        case namespace, name, displayName, version, downloadCount
    }
}

struct OpenVSXResponse: Decodable { var extensions: [OpenVSXExtension] }

@MainActor
final class ExtensionStore: ObservableObject {
    @Published var items: [OpenVSXExtension] = []
    @Published var query = ""
    @Published var status = "Search the Open VSX catalogue."
    @Published var isLoading = false

    func search() async {
        isLoading = true
        defer { isLoading = false }
        let term = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        guard let url = URL(string: "https://open-vsx.org/api/-/search?query=\(term)&size=30&sortBy=downloadCount") else { status = "Invalid search."; return }
        do {
            var request = URLRequest(url: url)
            request.timeoutInterval = 20
            let (data, _) = try await URLSession.shared.data(for: request)
            let response = try JSONDecoder().decode(OpenVSXResponse.self, from: data)
            items = response.extensions
            status = items.isEmpty ? "No extensions found." : "\(items.count) results · packages can be downloaded, but desktop extension activation is not supported yet."
        } catch { status = "Catalogue unavailable: \(error.localizedDescription)" }
    }

    func download(_ item: OpenVSXExtension) async -> String {
        let version = item.version ?? "latest"
        let urlString = "https://open-vsx.org/api/\(item.namespace)/\(item.name)/\(version)/file/\(item.namespace).\(item.name)-\(version).vsix"
        guard let url = URL(string: urlString) else { return "Invalid package URL." }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let folder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Extensions", isDirectory: true)
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            let destination = folder.appendingPathComponent("\(item.namespace).\(item.name)-\(version).vsix")
            try data.write(to: destination, options: .atomic)
            return "Saved package: \(destination.lastPathComponent). Activation is not implemented."
        } catch { return "Download failed: \(error.localizedDescription)" }
    }
}

struct ExtensionsView: View {
    @StateObject private var store = ExtensionStore()
    @State private var message = ""
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                TextField("Search Open VSX", text: $store.query)
                    .textFieldStyle(.roundedBorder).autocorrectionDisabled()
                    .onSubmit { Task { await store.search() } }
                Button { Task { await store.search() } } label: {
                    Image(systemName: "magnifyingglass").padding(10)
                }.disabled(store.isLoading)
            }.padding(.horizontal)
            Text(store.status).font(.caption).foregroundStyle(.secondary).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal)
            List(store.items) { item in
                VStack(alignment: .leading, spacing: 5) {
                    Text(item.displayName ?? item.name).font(.headline)
                    Text("\(item.namespace).\(item.name) · \(item.version ?? "version n/a")")
                        .font(.caption).foregroundStyle(.secondary)
                    Button("Download VSIX") {
                        Task { message = await store.download(item) }
                    }.font(.subheadline)
                }.padding(.vertical, 4)
            }
            if !message.isEmpty { Text(message).font(.caption).padding(.horizontal) }
        }.navigationTitle("Extensions")
    }
}

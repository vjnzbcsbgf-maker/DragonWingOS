import SwiftUI

struct TerminalView: View {
    @State private var command = ""
    @State private var output = "DragonWing Local Console\nType 'help' to see supported commands.\n\n"
    private var root: URL { FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Label("Local Console", systemImage: "terminal")
                Spacer()
                Text("SANDBOXED").font(.caption2.bold()).foregroundStyle(.green)
            }.padding()
            ScrollView {
                Text(output).font(.system(size: 13, design: .monospaced)).foregroundStyle(.green)
                    .frame(maxWidth: .infinity, alignment: .leading).padding()
            }
            .background(Color.black)
            HStack {
                Text("›").foregroundStyle(.cyan)
                TextField("command", text: $command)
                    .font(.system(.body, design: .monospaced))
                    .textInputAutocapitalization(.never).autocorrectionDisabled()
                    .onSubmit { runCommand() }
                Button("Run", action: runCommand).fontWeight(.semibold)
            }.padding().background(Color(.secondarySystemBackground))
        }
    }

    private func runCommand() {
        let raw = command.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !raw.isEmpty else { return }
        let parts = raw.split(separator: " ", maxSplits: 1).map(String.init)
        let name = parts.first ?? ""
        let arg = parts.count > 1 ? parts[1] : ""
        var result = ""
        switch name {
        case "help":
            result = "Supported: help, pwd, ls, cat <file>, echo <text>, date, uname, whoami, clear, touch <file>, mkdir <folder>"
        case "pwd": result = root.path
        case "whoami": result = "mobile-user"
        case "uname": result = "DragonWing-iOS (sandboxed runtime)"
        case "date": result = Date.now.formatted(date: .complete, time: .standard)
        case "echo": result = arg
        case "clear": output = ""; command = ""; return
        case "ls":
            let names = (try? FileManager.default.contentsOfDirectory(atPath: root.path)) ?? []
            result = names.isEmpty ? "(empty workspace)" : names.joined(separator: "\n")
        case "cat":
            let url = safeURL(arg)
            result = (try? String(contentsOf: url, encoding: .utf8)) ?? "Cannot read file: \(arg)"
        case "touch":
            let url = safeURL(arg)
            if arg.isEmpty { result = "Usage: touch <file>" }
            else { FileManager.default.createFile(atPath: url.path, contents: Data()); result = "Created \(arg)" }
        case "mkdir":
            let url = safeURL(arg)
            if arg.isEmpty { result = "Usage: mkdir <folder>" }
            else {
                do { try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true); result = "Created directory \(arg)" }
                catch { result = error.localizedDescription }
            }
        default: result = "Command not available in the iOS sandbox. Type 'help'."
        }
        output += "› \(raw)\n\(result)\n\n"
        command = ""
    }

    private func safeURL(_ path: String) -> URL {
        let clean = path.replacingOccurrences(of: "..", with: "").replacingOccurrences(of: "/", with: "")
        return root.appendingPathComponent(clean)
    }
}

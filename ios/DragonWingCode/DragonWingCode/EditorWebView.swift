import SwiftUI
import WebKit

struct EditorWebView: UIViewRepresentable {
    @Binding var text: String
    var theme: EditorTheme
    var language: String
    var onReady: (() -> Void)? = nil

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = false
        let view = WKWebView(frame: .zero, configuration: configuration)
        view.isOpaque = false
        view.backgroundColor = UIColor(theme.background)
        view.scrollView.backgroundColor = UIColor(theme.background)
        view.navigationDelegate = context.coordinator
        view.configuration.userContentController.add(context.coordinator, name: "editorChanged")
        if let url = Bundle.main.url(forResource: "editor", withExtension: "html", subdirectory: "Resources") ?? Bundle.main.url(forResource: "editor", withExtension: "html") {
            view.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        } else {
            view.loadHTMLString("<html><body><textarea style='width:100%;height:100%;background:#101522;color:white'></textarea></body></html>", baseURL: nil)
        }
        return view
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.backgroundColor = UIColor(theme.background)
        let payload: [String: Any] = ["text": text, "theme": theme.rawValue.lowercased(), "language": language]
        guard let data = try? JSONSerialization.data(withJSONObject: payload),
              let json = String(data: data, encoding: .utf8) else { return }
        uiView.evaluateJavaScript("window.dragonwingSetState && window.dragonwingSetState(\(json));")
    }

    final class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: EditorWebView
        init(_ parent: EditorWebView) { self.parent = parent }
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard message.name == "editorChanged", let value = message.body as? String else { return }
            DispatchQueue.main.async { self.parent.text = value }
        }
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.onReady?()
            let payload: [String: Any] = ["text": parent.text, "theme": parent.theme.rawValue.lowercased(), "language": parent.language]
            if let data = try? JSONSerialization.data(withJSONObject: payload), let json = String(data: data, encoding: .utf8) {
                webView.evaluateJavaScript("window.dragonwingSetState && window.dragonwingSetState(\(json));")
            }
        }
    }
}

import SwiftUI
import WebKit

/// Hosts the upstream Monaco editor in an offline, locally bundled WKWebView.
struct MonacoEditorView: UIViewRepresentable {
    @Binding var text: String
    var language: String

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> WKWebView {
        let controller = WKUserContentController()
        controller.add(context.coordinator, name: "dragonwingEditorChanged")
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = controller
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = false

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.isOpaque = false
        webView.backgroundColor = UIColor(red: 0.075, green: 0.085, blue: 0.11, alpha: 1)
        webView.scrollView.backgroundColor = webView.backgroundColor
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = false

        if let editorURL = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "Monaco") {
            webView.loadFileURL(editorURL, allowingReadAccessTo: editorURL.deletingLastPathComponent().appendingPathComponent("monaco"))
        } else {
            webView.loadHTMLString("<html><body style='background:#131722;color:white'>Monaco assets missing</body></html>", baseURL: nil)
        }
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        context.coordinator.parent = self
        let payload: [String: String] = ["text": text, "language": language]
        guard let data = try? JSONSerialization.data(withJSONObject: payload),
              let json = String(data: data, encoding: .utf8) else { return }
        webView.evaluateJavaScript("window.dragonwingSetState && window.dragonwingSetState(\(json));")
    }

    final class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: MonacoEditorView
        init(_ parent: MonacoEditorView) { self.parent = parent }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard message.name == "dragonwingEditorChanged", let value = message.body as? String else { return }
            DispatchQueue.main.async { self.parent.text = value }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            let payload: [String: String] = ["text": parent.text, "language": parent.language]
            guard let data = try? JSONSerialization.data(withJSONObject: payload),
                  let json = String(data: data, encoding: .utf8) else { return }
            webView.evaluateJavaScript("window.dragonwingSetState && window.dragonwingSetState(\(json));")
        }
    }
}

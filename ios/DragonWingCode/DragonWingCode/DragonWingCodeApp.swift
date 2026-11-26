import SwiftUI

@main
struct DragonWingCodeApp: App {
    @StateObject private var themes = ThemeStore()
    var body: some Scene {
        WindowGroup {
            WorkspaceView().environmentObject(themes)
        }
    }
}

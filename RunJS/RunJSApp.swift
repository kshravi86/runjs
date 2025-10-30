import SwiftUI

@main
struct RunJSApp: App {
    init() {
        print("[RunJSApp] App initialized")
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    print("[RunJSApp] ContentView appeared in WindowGroup")
                }
        }
    }
}

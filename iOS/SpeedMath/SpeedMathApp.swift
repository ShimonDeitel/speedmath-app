import SwiftUI

@main
struct SpeedMathApp: App {
    @State private var proStore = ProStore()
    @State private var statsStore = StatsStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(proStore)
                .environment(statsStore)
                .task {
                    proStore.startListening()
                    await proStore.load()
                }
        }
    }
}

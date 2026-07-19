import SwiftUI

@main
struct SpeedMathApp: App {
    @State private var proStore = ProStore()
    @State private var statsStore = StatsStore()
    @State private var adsCoordinator = AdsCoordinator()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(proStore)
                .environment(statsStore)
                .environment(adsCoordinator)
                .task {
                    proStore.startListening()
                    await proStore.load()
                    if !CommandLine.arguments.contains("-uitest") {
                        await adsCoordinator.start()
                    }
                }
        }
    }
}

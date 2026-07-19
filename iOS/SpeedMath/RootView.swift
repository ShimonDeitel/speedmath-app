import SwiftUI

struct RootView: View {
    var body: some View {
        NavigationStack {
            HomeView()
        }
        .tint(Color.smTangerine)
    }
}

#Preview {
    RootView()
        .environment(ProStore())
        .environment(StatsStore())
        .environment(AdsCoordinator())
}

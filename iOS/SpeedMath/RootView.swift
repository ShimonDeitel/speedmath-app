import SwiftUI

struct RootView: View {
    @State private var showProfile = false

    var body: some View {
        NavigationStack {
            HomeView(showProfile: $showProfile)
        }
        .sheet(isPresented: $showProfile) {
            ProfileView()
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

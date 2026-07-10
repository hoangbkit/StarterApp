import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: StoreManager
    @State private var isShowingPaywall = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 72, height: 72)
                    .foregroundStyle(.green)

                Text("You're all set!")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("This is the main app screen.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if store.isPro {
                    Label("Pro unlocked", systemImage: "star.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.orange)
                        .padding(.top, 8)
                } else {
                    Button("Upgrade to Pro") {
                        isShowingPaywall = true
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.black)
                    .padding(.top, 8)
                }
            }
            .padding()
            .navigationTitle("Demo")
        }
        .sheet(isPresented: $isShowingPaywall) {
            PaywallView()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(StoreManager())
}

import SwiftUI

struct ContentView: View {
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
            }
            .padding()
            .navigationTitle("Demo")
        }
    }
}

#Preview {
    ContentView()
}

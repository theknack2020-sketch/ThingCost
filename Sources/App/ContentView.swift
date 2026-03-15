import SwiftUI

struct ContentView: View {
    var body: some View {
        ItemListView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}

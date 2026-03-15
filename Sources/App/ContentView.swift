import SwiftUI

struct ContentView: View {
    var body: some View {
        ItemListView()
    }
}

#Preview {
    ContentView()
        .environment(StoreService.shared)
        .modelContainer(for: Item.self, inMemory: true)
}

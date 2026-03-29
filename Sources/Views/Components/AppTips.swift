import TipKit

// MARK: - Add First Item Tip

struct AddFirstItemTip: Tip {
    var title: Text {
        Text("Track Your First Item")
    }

    var message: Text? {
        Text("Tap + to add something you own and see its daily cost.")
    }

    var image: Image? {
        Image(systemName: "plus.circle.fill")
    }

    @Parameter
    static var hasAddedItem: Bool = false

    var rules: [Rule] {
        [
            #Rule(Self.$hasAddedItem) { $0 == false },
        ]
    }
}

// MARK: - Log Use Tip

struct LogUseTip: Tip {
    var title: Text {
        Text("Log Your Usage")
    }

    var message: Text? {
        Text("Tap \"Log Use\" to track how often you use this item. More uses = better value!")
    }

    var image: Image? {
        Image(systemName: "hand.tap.fill")
    }

    @Parameter
    static var viewCount: Int = 0

    var rules: [Rule] {
        [
            #Rule(Self.$viewCount) { $0 >= 1 },
        ]
    }

    var options: [TipOption] {
        MaxDisplayCount(2)
    }
}

// MARK: - Share Card Tip

struct ShareCardTip: Tip {
    var title: Text {
        Text("Share Your Stats")
    }

    var message: Text? {
        Text("Create a beautiful share card to show friends the real cost of your stuff.")
    }

    var image: Image? {
        Image(systemName: "square.and.arrow.up")
    }

    @Parameter
    static var viewCount: Int = 0

    var rules: [Rule] {
        [
            #Rule(Self.$viewCount) { $0 >= 3 },
        ]
    }

    var options: [TipOption] {
        MaxDisplayCount(1)
    }
}

// MARK: - Warranty Tip

struct WarrantyTip: Tip {
    var title: Text {
        Text("Track Warranties")
    }

    var message: Text? {
        Text("Add warranty dates when creating items to get reminded before they expire.")
    }

    var image: Image? {
        Image(systemName: "shield.checkered")
    }

    var options: [TipOption] {
        MaxDisplayCount(1)
    }
}

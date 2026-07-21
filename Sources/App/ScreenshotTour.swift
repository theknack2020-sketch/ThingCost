#if DEBUG
    import Foundation

    /// Store-screenshot pipeline support (store-shots skill). Routes the app to an
    /// exact screen per panel via `-uiState`, selects hero content via `-heroIndex`,
    /// and suppresses popups (tips, achievements) that would photobomb a capture.
    /// DEBUG-only; zero release impact.
    enum ScreenshotTour {
        enum State: String {
            case list
            case detail
            case dashboard
            case share
            case settings
        }

        static var state: State? {
            let args = ProcessInfo.processInfo.arguments
            guard let i = args.firstIndex(of: "-uiState"), args.indices.contains(i + 1)
            else { return nil }
            return State(rawValue: args[i + 1])
        }

        static var isActive: Bool { state != nil }

        /// Index into the item list sorted by daily cost (descending) — panels must
        /// never share hero content (duplicate-raw lint).
        static var heroIndex: Int {
            let args = ProcessInfo.processInfo.arguments
            guard let i = args.firstIndex(of: "-heroIndex"), args.indices.contains(i + 1)
            else { return 0 }
            return Int(args[i + 1]) ?? 0
        }
    }
#endif

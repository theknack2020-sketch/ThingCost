import AudioToolbox
import SwiftUI

@MainActor
final class SoundManager {
    static let shared = SoundManager()

    @AppStorage("soundEnabled") var soundEnabled = true

    private init() {}

    // MARK: - System Sounds

    func playTap() {
        guard soundEnabled else { return }
        AudioServicesPlaySystemSound(1104)
    }

    func playSave() {
        guard soundEnabled else { return }
        AudioServicesPlaySystemSound(1001)
    }

    func playDelete() {
        guard soundEnabled else { return }
        AudioServicesPlaySystemSound(1155)
    }

    func playError() {
        guard soundEnabled else { return }
        AudioServicesPlaySystemSound(1053)
    }

    func playCelebrate() {
        guard soundEnabled else { return }
        AudioServicesPlaySystemSound(1025)
    }
}

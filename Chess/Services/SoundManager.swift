import AVFoundation

class SoundManager {
    static let shared = SoundManager()

    private var audioPlayer: AVAudioPlayer?

    func playMoveSound() {
        AudioServicesPlaySystemSound(1104)
    }

    func playCaptureSound() {
        AudioServicesPlaySystemSound(1103)
    }

    func playSuccessSound() {
        AudioServicesPlaySystemSound(1022)
    }
}

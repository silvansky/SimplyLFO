import Foundation
import SwiftUI

class LFOInstance: ObservableObject, Identifiable {
    let id = UUID()
    let lfo = LFO()

    @Published var rate: Double = 2.0
    @Published var depth: Double = 0.5
    @Published var waveform: LFO.Waveform = .sine
    @Published var ccValue: Double = 0.0
    @Published var isRunning = false
    @Published var selectedCC: UInt8 = 74

    private var timer: Timer?
    private weak var midiManager: MIDIManager?

    init(midiManager: MIDIManager) {
        self.midiManager = midiManager
    }

    func start() {
        stop()
        lfo.rate = rate
        lfo.depth = depth
        lfo.waveform = waveform
        lfo.phase = 0

        timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { [weak self] _ in
            self?.update()
        }
        isRunning = true
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }

    private func update() {
        lfo.rate = rate
        lfo.depth = depth
        lfo.waveform = waveform

        let value = lfo.update()
        ccValue = value

        let midiValue = UInt8((value + 1.0) * 63.5)
        midiManager?.sendCC(midiValue, controller: selectedCC)
    }
}

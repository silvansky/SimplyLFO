import Foundation
import SwiftUI

class LFOInstance: ObservableObject, Identifiable {
    let id = UUID()
    let lfo = LFO()

    @Published var rate: Double = 2.0
    @Published var depth: Double = 0.5
    @Published var offset: Double = 0.5
    @Published var waveform: LFO.Waveform = .sine
    @Published var isRunning = false
    @Published var selectedCC: UInt8 = 74

    var ccValue: Double = 0.0
    var midiValue: UInt8 = 64
    weak var midiManager: MIDIManager?

    init(midiManager: MIDIManager) {
        self.midiManager = midiManager
    }

    func start() {
        lfo.rate = rate
        lfo.depth = depth
        lfo.waveform = waveform
        lfo.phase = 0
        isRunning = true
    }

    func stop() {
        isRunning = false
    }

    func update() {
        guard isRunning else { return }
        lfo.rate = rate
        lfo.depth = depth
        lfo.waveform = waveform

        let value = lfo.update()
        ccValue = value

        let center = offset * 127.0
        let swing = value * 63.5
        midiValue = UInt8(max(0, min(127, center + swing)))
        midiManager?.sendCC(midiValue, controller: selectedCC)
    }
}

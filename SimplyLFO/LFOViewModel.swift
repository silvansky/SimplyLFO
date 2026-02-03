import Foundation
import SwiftUI
import AudioKit
import AudioKitUI
import CoreMIDI

struct CCController: Identifiable {
    var id: UInt8
    var name: String
}

class LFOViewModel: ObservableObject {
    @Published var rate: Double = 2.0
    @Published var depth: Double = 0.5
    @Published var waveform: LFO.Waveform = .sine
    @Published var ccValue: Double = 0.0
    @Published var isSending = false
    @Published var selectedCCController: UInt8 = 74

    let lfo = LFO()
    var midiManager = MIDIManager()
    private var timer: Timer?

    // Common MIDI CC controllers with their names
    let ccControllers: [CCController] = [
        CCController(id: 1, name: "Modulation Wheel"),
        CCController(id: 2, name: "Breath Controller"),
        CCController(id: 7, name: "Volume"),
        CCController(id: 10, name: "Pan"),
        CCController(id: 11, name: "Expression"),
        CCController(id: 64, name: "Sustain Pedal"),
        CCController(id: 71, name: "Resonance"),
        CCController(id: 72, name: "Release Time"),
        CCController(id: 73, name: "Attack Time"),
        CCController(id: 74, name: "Cutoff Frequency"),
        CCController(id: 91, name: "Reverb Level"),
        CCController(id: 93, name: "Chorus Level")
    ]

    init() {
        midiManager.refreshDestinations()
        if midiManager.destinations.count > 0 {
            midiManager.connect(to: 0)
        }
    }

    func start() {
        stop()
        lfo.rate = rate
        lfo.depth = depth
        lfo.waveform = waveform
        lfo.phase = 0

        timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
            self.updateLFO()
        }
        isSending = true
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        isSending = false
    }

    private func updateLFO() {
        lfo.rate = rate
        lfo.depth = depth
        lfo.waveform = waveform

        let lfoValue = lfo.update()
        ccValue = lfoValue

        // Convert bipolar (-1.0 to 1.0) to unipolar (0 to 127)
        let midiValue = UInt8((lfoValue + 1.0) * 63.5)
        midiManager.sendCC(midiValue, controller: selectedCCController)
    }

    func waveformName(_ waveform: LFO.Waveform) -> String {
        switch waveform {
        case .sine: return "Sine"
        case .triangle: return "Triangle"
        case .square: return "Square"
        case .sawtooth: return "Sawtooth"
        }
    }

    func getControllerName(for id: UInt8) -> String {
        if let controller = ccControllers.first(where: { $0.id == id }) {
            return controller.name
        }
        return "CC \(id)"
    }
}

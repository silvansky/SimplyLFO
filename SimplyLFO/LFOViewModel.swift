import Foundation
import SwiftUI

struct CCController: Identifiable {
    var id: UInt8
    var name: String
}

class LFOViewModel: ObservableObject {
    @Published var lfos: [LFOInstance] = []
    @Published var midiManager = MIDIManager()

    static let ccControllers: [CCController] = [
        CCController(id: 1, name: "Mod Wheel"),
        CCController(id: 2, name: "Breath"),
        CCController(id: 7, name: "Volume"),
        CCController(id: 10, name: "Pan"),
        CCController(id: 11, name: "Expression"),
        CCController(id: 64, name: "Sustain"),
        CCController(id: 71, name: "Resonance"),
        CCController(id: 72, name: "Release"),
        CCController(id: 73, name: "Attack"),
        CCController(id: 74, name: "Cutoff"),
        CCController(id: 91, name: "Reverb"),
        CCController(id: 93, name: "Chorus")
    ]

    init() {
        midiManager.refreshDestinations()
        if midiManager.destinations.count > 0 {
            midiManager.connect(to: 0)
        }
        addLFO()
    }

    func addLFO() {
        let instance = LFOInstance(midiManager: midiManager)
        lfos.append(instance)
    }

    func removeLFO(_ lfo: LFOInstance) {
        lfo.stop()
        lfos.removeAll { $0.id == lfo.id }
    }

    static func waveformName(_ waveform: LFO.Waveform) -> String {
        switch waveform {
        case .sine: return "Sin"
        case .triangle: return "Tri"
        case .square: return "Sqr"
        case .sawtooth: return "Saw"
        }
    }
}

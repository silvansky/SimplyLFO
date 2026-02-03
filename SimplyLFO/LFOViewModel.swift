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
        CCController(id: 3, name: "Undefined 3"),
        CCController(id: 4, name: "Foot"),
        CCController(id: 5, name: "Portamento Time"),
        CCController(id: 7, name: "Volume"),
        CCController(id: 8, name: "Balance"),
        CCController(id: 10, name: "Pan"),
        CCController(id: 11, name: "Expression"),
        CCController(id: 12, name: "Effect 1"),
        CCController(id: 13, name: "Effect 2"),
        CCController(id: 16, name: "GP 1"),
        CCController(id: 17, name: "GP 2"),
        CCController(id: 18, name: "GP 3"),
        CCController(id: 19, name: "GP 4"),
        CCController(id: 64, name: "Sustain"),
        CCController(id: 65, name: "Portamento"),
        CCController(id: 66, name: "Sostenuto"),
        CCController(id: 67, name: "Soft Pedal"),
        CCController(id: 68, name: "Legato"),
        CCController(id: 69, name: "Hold 2"),
        CCController(id: 70, name: "Sound Variation"),
        CCController(id: 71, name: "Resonance"),
        CCController(id: 72, name: "Release"),
        CCController(id: 73, name: "Attack"),
        CCController(id: 74, name: "Cutoff"),
        CCController(id: 75, name: "Decay"),
        CCController(id: 76, name: "Vibrato Rate"),
        CCController(id: 77, name: "Vibrato Depth"),
        CCController(id: 78, name: "Vibrato Delay"),
        CCController(id: 79, name: "Sound Ctrl 10"),
        CCController(id: 80, name: "GP 5"),
        CCController(id: 81, name: "GP 6"),
        CCController(id: 82, name: "GP 7"),
        CCController(id: 83, name: "GP 8"),
        CCController(id: 85, name: "Undefined 85"),
        CCController(id: 86, name: "Undefined 86"),
        CCController(id: 87, name: "Undefined 87"),
        CCController(id: 88, name: "Undefined 88"),
        CCController(id: 89, name: "Undefined 89"),
        CCController(id: 90, name: "Undefined 90"),
        CCController(id: 91, name: "Reverb"),
        CCController(id: 92, name: "Tremolo"),
        CCController(id: 93, name: "Chorus"),
        CCController(id: 94, name: "Detune"),
        CCController(id: 95, name: "Phaser"),
        CCController(id: 102, name: "Undefined 102"),
        CCController(id: 103, name: "Undefined 103"),
        CCController(id: 104, name: "Undefined 104"),
        CCController(id: 105, name: "Undefined 105"),
        CCController(id: 106, name: "Undefined 106"),
        CCController(id: 107, name: "Undefined 107"),
        CCController(id: 108, name: "Undefined 108"),
        CCController(id: 109, name: "Undefined 109"),
        CCController(id: 110, name: "Undefined 110"),
        CCController(id: 111, name: "Undefined 111"),
        CCController(id: 112, name: "Undefined 112"),
        CCController(id: 113, name: "Undefined 113"),
        CCController(id: 114, name: "Undefined 114"),
        CCController(id: 115, name: "Undefined 115"),
        CCController(id: 116, name: "Undefined 116"),
        CCController(id: 117, name: "Undefined 117"),
        CCController(id: 118, name: "Undefined 118"),
        CCController(id: 119, name: "Undefined 119")
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
        case .reverseSawtooth: return "rSaw"
        case .sampleAndHold: return "S&H"
        case .noise: return "Noise"
        case .exponential: return "Exp"
        case .stepped: return "Step"
        case .smoothRandom: return "Rnd"
        }
    }
}

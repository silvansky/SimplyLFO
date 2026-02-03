import Foundation
import SwiftUI
import AudioKit
import AudioKitUI
import CoreMIDI

class LFO {
    enum Waveform {
        case sine, triangle, square, sawtooth
    }
    
    var waveform: Waveform = .sine
    var rate: Double = 1.0  // Hz
    var depth: Double = 1.0 // 0.0 to 1.0
    var phase: Double = 0.0
    private var lastUpdate: CFTimeInterval = CACurrentMediaTime()
    
    func update() -> Double {
        let now = CACurrentMediaTime()
        let deltaTime = now - lastUpdate
        lastUpdate = now
        
        phase += rate * deltaTime
        phase = phase.truncatingRemainder(dividingBy: 1.0)
        
        let value: Double
        switch waveform {
        case .sine:
            value = sin(phase * 2 * .pi)
        case .triangle:
            value = abs(phase * 4 - 2) - 1
        case .square:
            value = phase < 0.5 ? 1.0 : -1.0
        case .sawtooth:
            value = phase * 2 - 1
        }
        
        return value * depth
    }
}

extension LFO.Waveform: CaseIterable, Hashable {}

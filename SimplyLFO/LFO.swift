import Foundation
import QuartzCore

class LFO {
    enum Waveform: CaseIterable, Hashable {
        case sine, triangle, square, sawtooth, reverseSawtooth
        case sampleAndHold, noise, exponential, stepped, smoothRandom
    }

    var waveform: Waveform = .sine
    var rate: Double = 1.0
    var depth: Double = 1.0
    var phase: Double = 0.0
    private var lastUpdate: CFTimeInterval = CACurrentMediaTime()

    private var heldValue: Double = 0.0
    private var lastPhase: Double = 0.0
    private var randomFrom: Double = 0.0
    private var randomTo: Double = 0.0

    func update() -> Double {
        let now = CACurrentMediaTime()
        let deltaTime = now - lastUpdate
        lastUpdate = now

        let prevPhase = phase
        phase += rate * deltaTime
        phase = phase.truncatingRemainder(dividingBy: 1.0)

        let cycleReset = phase < prevPhase

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
        case .reverseSawtooth:
            value = 1 - phase * 2
        case .sampleAndHold:
            if cycleReset { heldValue = Double.random(in: -1...1) }
            value = heldValue
        case .noise:
            value = Double.random(in: -1...1)
        case .exponential:
            value = (exp(phase * 3) - 1) / (exp(3) - 1) * 2 - 1
        case .stepped:
            let steps = 8.0
            let tri = abs(phase * 4 - 2) - 1
            value = (tri * steps).rounded() / steps
        case .smoothRandom:
            if cycleReset {
                randomFrom = randomTo
                randomTo = Double.random(in: -1...1)
            }
            let t = phase * phase * (3 - 2 * phase)
            value = randomFrom + (randomTo - randomFrom) * t
        }

        return value * depth
    }
}

import Foundation
import SwiftUI
import AudioKit
import AudioKitUI
import CoreMIDI

struct WaveformPickerView: View {
    @Binding var selectedWaveform: LFO.Waveform
    let viewModel: LFOViewModel
    
    var body: some View {
        Picker("Waveform", selection: $selectedWaveform) {
            ForEach(LFO.Waveform.allCases, id: \.self) { waveform in
                Text(viewModel.waveformName(waveform)).tag(waveform)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }
}

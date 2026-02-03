import SwiftUI
import AudioKit
import AudioKitUI
import CoreMIDI

struct ContentView: View {
    @StateObject private var viewModel = LFOViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Text("LFO MIDI Controller")
                .font(.title)
                .bold()

            // Waveform Selection
            VStack(alignment: .leading) {
                Text("Waveform")
                    .font(.headline)
                WaveformPickerView(selectedWaveform: $viewModel.waveform, viewModel: viewModel)
            }

            // Rate Control
            VStack {
                Text("Rate: \(viewModel.rate, specifier: "%.1f") Hz")
                    .font(.headline)
                Slider(value: $viewModel.rate, in: 0.1...20.0, step: 0.1)
            }

            // Depth Control
            VStack {
                Text("Depth: \(Int(viewModel.depth * 100))%")
                    .font(.headline)
                Slider(value: $viewModel.depth, in: 0.0...1.0)
            }

            // MIDI Destination
            VStack(alignment: .leading) {
                Text("MIDI Destination")
                    .font(.headline)
                Picker("Destination", selection: $viewModel.midiManager.selectedDestination) {
                    ForEach(0..<viewModel.midiManager.destinations.count, id: \.self) { index in
                        Text(viewModel.midiManager.destinations[index]).tag(index)
                    }
                }
                .onChange(of: viewModel.midiManager.selectedDestination) { newValue in
                    viewModel.midiManager.connect(to: newValue)
                }

                Button("Refresh Destinations") {
                    viewModel.midiManager.refreshDestinations()
                }
            }
            // CC Controller Picker
            VStack(alignment: .leading) {
                Text("MIDI CC Controller")
                    .font(.headline)
                Picker("Controller", selection: $viewModel.selectedCCController) {
                    ForEach(viewModel.ccControllers) { controller in
                        Text("\(controller.id): \(controller.name)").tag(controller.id)
                    }
                }
            }

            // LFO Visualization
            VStack {
                Text("LFO Output")
                    .font(.headline)
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 40)

                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: CGFloat((viewModel.ccValue + 1) * 100), height: 40)
                }
                Text("CC Value: \(Int((viewModel.ccValue + 1) * 63.5))")
            }

            // Control Buttons
            HStack {
                Button(viewModel.isSending ? "Stop" : "Start") {
                    if viewModel.isSending {
                        viewModel.stop()
                    } else {
                        viewModel.start()
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
        }
        .padding()
        .frame(minWidth: 400, minHeight: 500)
    }
}

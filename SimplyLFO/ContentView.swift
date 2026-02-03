import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = LFOViewModel()

    var body: some View {
        VStack(spacing: 16) {
            // Header with MIDI destination
            HStack {
                Text("SimplyLFO")
                    .font(.title2)
                    .bold()

                Spacer()

                Picker("MIDI", selection: $viewModel.midiManager.selectedDestination) {
                    ForEach(0..<viewModel.midiManager.destinations.count, id: \.self) { index in
                        Text(viewModel.midiManager.destinations[index]).tag(index)
                    }
                }
                .frame(width: 200)
                .onChange(of: viewModel.midiManager.selectedDestination) { newValue in
                    viewModel.midiManager.connect(to: newValue)
                }

                Button(action: { viewModel.midiManager.refreshDestinations() }) {
                    Image(systemName: "arrow.clockwise")
                }
            }

            Divider()

            // LFO list in scroll view
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(viewModel.lfos) { lfo in
                        LFORowView(lfo: lfo) {
                            if viewModel.lfos.count > 1 {
                                viewModel.removeLFO(lfo)
                            }
                        }
                    }
                }
            }

            // Add button
            Button(action: { viewModel.addLFO() }) {
                Label("Add LFO", systemImage: "plus.circle.fill")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(minWidth: 700, minHeight: 200)
    }
}

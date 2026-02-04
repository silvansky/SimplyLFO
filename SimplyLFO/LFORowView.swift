import SwiftUI

struct LFORowView: View {
    @ObservedObject var lfo: LFOInstance
    var onRemove: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Waveform picker
            Picker("", selection: $lfo.waveform) {
                ForEach(LFO.Waveform.allCases, id: \.self) { waveform in
                    Text(LFOViewModel.waveformName(waveform)).tag(waveform)
                }
            }
            .frame(width: 70)

            // Rate, Depth & Offset sliders stacked
            VStack(spacing: 4) {
                HStack {
                    Text("Rate")
                        .font(.caption)
                        .frame(width: 35, alignment: .leading)
                    Slider(value: $lfo.rate, in: 0.01...20.0)
                    Text("\(lfo.rate, specifier: "%.2f")")
                        .font(.caption)
                        .frame(width: 30)
                }
                HStack {
                    Text("Depth")
                        .font(.caption)
                        .frame(width: 35, alignment: .leading)
                    Slider(value: $lfo.depth, in: 0.0...1.0)
                    Text("\(Int(lfo.depth * 100))%")
                        .font(.caption)
                        .frame(width: 30)
                }
                HStack {
                    Text("Offset")
                        .font(.caption)
                        .frame(width: 35, alignment: .leading)
                    Slider(value: $lfo.offset, in: 0.0...1.0)
                    Text("\(Int((lfo.offset - 0.5) * 200))%")
                        .font(.caption)
                        .frame(width: 40)
                }
            }
            .frame(width: 200)

            // CC picker
            Picker("", selection: $lfo.selectedCC) {
                ForEach(LFOViewModel.ccControllers) { cc in
                    Text("\(cc.id): \(cc.name)").tag(cc.id)
                }
            }
            .frame(width: 130)

            // Oscilloscope indicator
            WaveformView(lfoInstance: lfo)
                .frame(width: 80)
                .cornerRadius(4)

            // Start/Stop
            Button(lfo.isRunning ? "Stop" : "Start") {
                if lfo.isRunning {
                    lfo.stop()
                } else {
                    lfo.start()
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(lfo.isRunning ? .red : .green)
            .frame(width: 60)

            // Remove
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

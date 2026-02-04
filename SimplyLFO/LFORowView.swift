import SwiftUI
import AppKit

class WaveformNSView: NSView {
    weak var lfoInstance: LFOInstance?
    private var displayLink: CVDisplayLink?

    override init(frame: NSRect) {
        super.init(frame: frame)
        wantsLayer = true
        layer?.backgroundColor = NSColor.black.cgColor
        setupDisplayLink()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }

    private func setupDisplayLink() {
        CVDisplayLinkCreateWithActiveCGDisplays(&displayLink)
        guard let displayLink = displayLink else { return }

        CVDisplayLinkSetOutputCallback(displayLink, { _, _, _, _, _, userInfo -> CVReturn in
            let view = Unmanaged<WaveformNSView>.fromOpaque(userInfo!).takeUnretainedValue()
            DispatchQueue.main.async { view.needsDisplay = true }
            return kCVReturnSuccess
        }, Unmanaged.passUnretained(self).toOpaque())

        CVDisplayLinkStart(displayLink)
    }

    deinit {
        if let displayLink = displayLink {
            CVDisplayLinkStop(displayLink)
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        guard let context = NSGraphicsContext.current?.cgContext,
              let lfo = lfoInstance else { return }

        let history = lfo.valueHistory
        guard history.count > 1 else { return }

        context.setStrokeColor(NSColor.green.cgColor)
        context.setLineWidth(1.5)

        let stepX = bounds.width / CGFloat(lfo.historySize - 1)

        context.beginPath()
        for (i, value) in history.enumerated() {
            let x = CGFloat(lfo.historySize - history.count + i) * stepX
            let y = CGFloat(value) / 127.0 * bounds.height
            if i == 0 {
                context.move(to: CGPoint(x: x, y: y))
            } else {
                context.addLine(to: CGPoint(x: x, y: y))
            }
        }
        context.strokePath()
    }
}

struct WaveformView: NSViewRepresentable {
    let lfoInstance: LFOInstance

    func makeNSView(context: Context) -> WaveformNSView {
        let view = WaveformNSView()
        view.lfoInstance = lfoInstance
        return view
    }

    func updateNSView(_ nsView: WaveformNSView, context: Context) {
        nsView.lfoInstance = lfoInstance
    }
}

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
                    Text("\(Int(lfo.offset * 127))")
                        .font(.caption)
                        .frame(width: 30)
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

import SwiftUI
import AppKit

class WaveformNSView: NSView {
    weak var lfoInstance: LFOInstance?
    private var displayLink: CADisplayLink?

    override init(frame: NSRect) {
        super.init(frame: frame)
        wantsLayer = true
        layer?.backgroundColor = NSColor.black.cgColor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        if window != nil {
            displayLink = displayLink(target: self, selector: #selector(refresh))
            displayLink?.add(to: .main, forMode: .common)
        } else {
            displayLink?.invalidate()
            displayLink = nil
        }
    }

    @objc private func refresh(_ link: CADisplayLink) {
        needsDisplay = true
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

import Foundation
import CoreMIDI

class MIDIManager: ObservableObject {
    private var midiClient = MIDIClientRef()
    private var midiOutputPort = MIDIPortRef()
    private var midiDestination: MIDIEndpointRef?

    @Published var isConnected = false
    @Published var destinations: [String] = []
    @Published var selectedDestination = 0

    init() {
        setupMIDI()
    }

    private func setupMIDI() {
        MIDIClientCreate("LFOClient" as CFString, nil, nil, &midiClient)
        MIDIOutputPortCreate(midiClient, "LFOOutputPort" as CFString, &midiOutputPort)
        refreshDestinations()
    }

    func refreshDestinations() {
        destinations.removeAll()
        let count = MIDIGetNumberOfDestinations()
        for i in 0..<count {
            let endpoint = MIDIGetDestination(i)
            var name: Unmanaged<CFString>?
            MIDIObjectGetStringProperty(endpoint, kMIDIPropertyDisplayName, &name)
            if let name = name?.takeRetainedValue() {
                destinations.append(name as String)
            }
        }
        if destinations.isEmpty {
            destinations = ["No MIDI Destinations"]
        }
        isConnected = destinations.count > 1 || (destinations.count == 1 && destinations[0] != "No MIDI Destinations")
    }

    func connect(to index: Int) {
        guard index < destinations.count else { return }
        midiDestination = MIDIGetDestination(index)
        selectedDestination = index
    }

    func sendCC(_ value: UInt8, controller: UInt8, channel: UInt8 = 0) {
        guard let destination = midiDestination else { return }

        var packet = MIDIPacket()
        packet.data.0 = 0xB0 + channel
        packet.data.1 = controller
        packet.data.2 = value
        packet.length = 3
        packet.timeStamp = 0

        var packetList = MIDIPacketList(numPackets: 1, packet: packet)
        MIDISend(midiOutputPort, destination, &packetList)
    }
}

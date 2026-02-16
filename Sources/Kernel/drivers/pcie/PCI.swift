
final class PCI: Sendable {
    static let shared = PCI()
}

// MARK: Scan
extension PCI {
    func scan() {
        logger.log("PCI: scan: executing...")
        for bus in 0...255 {
            for slot in 0...31 {
                let device = PCIDevice(
                    bus: UInt8(bus),
                    slot: UInt8(slot),
                    function: 0
                )
                if device.vendorID == 0xFFFF {
                    // no device is present
                    continue
                }
                logger.log("PCI: scan: found device: Vendor 0x\(String(device.vendorID, radix: 16)) at \(bus):\(slot)")
                if device.classCode == 0x02 {
                    logger.log("PCI: scan: found network controller")
                    // TODO: setup network driver for device
                }
            }
        }
        logger.log("PCI: scan: executed")
    }
}
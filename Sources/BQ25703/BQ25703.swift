import Foundation
import PeripheryKit

@main
struct BQ25703 {
    static func main() {
        let i2c = I2CTransfer(chip: .i2c("/dev/i2c-2"), address: 0x6b)
        let value = i2c.readUInt8(register: .byte(0x2E))
        print("[BQ25703] read manufacturer id \(value ?? 0)")
        guard value == 0x40 else {
            print("[BQ25703] can not found bq25703")
            return
        }

        // Found BQ25703
        while true {
            guard let chargeStatus = i2c.readBigEndianUInt16(register: .msb_lsb(0x2120)) else {
                print("[BQ25703] read ChargeCurrent failed")
                return
            }

            print("[BQ25703] Charge Current = \((chargeStatus & 0x8000) >> 15)")
            Thread.sleep(forTimeInterval: 1)
        }  
    }
}
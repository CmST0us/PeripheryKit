import Foundation

extension UInt16 {
    func toData() -> Data {
        var value = self
        return withUnsafeBytes(of: &value) { Data($0) }
    }
}

extension UInt32 {
    func toData() -> Data {
        var value = self
        return withUnsafeBytes(of: &value) { Data($0) }
    }
}
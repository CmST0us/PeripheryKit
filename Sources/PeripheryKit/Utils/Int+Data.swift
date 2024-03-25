import Foundation

extension UInt16 {
    public func toData() -> Data {
        var value = self
        return withUnsafeBytes(of: &value) { Data($0) }
    }
}

extension UInt32 {
    public func toData() -> Data {
        var value = self
        return withUnsafeBytes(of: &value) { Data($0) }
    }
}

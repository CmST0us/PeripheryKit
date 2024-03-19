import Foundation

extension Data {
    func toUInt16() -> UInt16? {
        // Ensure data has at least 2 bytes
        guard count >= MemoryLayout<UInt16>.size else {
            return nil
        }
        
        // Extract bytes
        var value: UInt16 = 0
        _ = Swift.withUnsafeMutableBytes(of: &value) { bytesPtr in
            copyBytes(to: bytesPtr.bindMemory(to: UInt8.self).baseAddress!, count: MemoryLayout<UInt16>.size)
        }
        
        // Convert to host byte order if needed
        return value
    }

    func toUInt32() -> UInt32? {
        // Ensure data has at least 4 bytes
        guard count >= MemoryLayout<UInt32>.size else {
            return nil
        }
        
        // Extract bytes
        var value: UInt32 = 0
        _ = Swift.withUnsafeMutableBytes(of: &value) { bytesPtr in
            copyBytes(to: bytesPtr.bindMemory(to: UInt8.self).baseAddress!, count: MemoryLayout<UInt32>.size)
        }
        
        // Convert to host byte order if needed
        return value
    }

    func toLittleEndianUInt16() -> UInt16? {
        guard let value = toUInt16() else {
            return nil
        }
        return UInt16(littleEndian: value)
    }

    func toBigEndianUInt16() -> UInt16? {
        guard let value = toUInt16() else {
            return nil
        }
        return UInt16(bigEndian: value)
    }

    func toLittleEndianUInt32() -> UInt32? {
        guard let value = toUInt32() else {
            return nil
        }
        return UInt32(littleEndian: value)
    }

    func toBigEndianUInt32() -> UInt32? {
        guard let value = toUInt32() else {
            return nil
        }
        return UInt32(bigEndian: value)
    }
}
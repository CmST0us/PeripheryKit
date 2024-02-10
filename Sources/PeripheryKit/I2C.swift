//
//  I2C.swift
//
//
//  Created by Eric Wu on 2024/2/7.
//

import Foundation
import Cperiphery

// MARK: - I2C Device
public class I2C {
    public enum Chip {
        case i2c(String)
    }
    
    public enum Flag: UInt16 {
        case NONE = 0x0000
        case RD = 0x0001
        case TEN = 0x0010
        case DMA_SAFE = 0x0200
        case RECV_LEN = 0x0400
        case NO_RD_ACK = 0x0800
        case IGNORE_NAK = 0x1000
        case REV_DIR_ADDR = 0x2000
        case NOSTART = 0x4000
        case STOP = 0x8000
    }
    
    public class Request {
        public var address: UInt16 = 0
        
        public var data: Data
        
        public var flags: Flag
        
        public init(address: UInt16, flags: Flag, data: Data) {
            self.address = address
            self.data = data
            self.flags = flags
        }
    }
    
    public class Response {
        public private(set) var request: Request
        
        public private(set) var flags: Flag
        
        public private(set) var data: Data
        
        init(request: Request, flags: Flag, data: Data) {
            self.request = request
            self.flags = flags
            self.data = data
        }
    }
    
    public let chip: Chip
    
    private var i2cHandle: OpaquePointer?
    
    deinit {
        close()
    }
    
    public init(chip: Chip) {
        self.chip = chip
    }
    
    @discardableResult
    public func open() -> Bool {
        switch chip {
        case .i2c(let path):
            let i2cHandle = i2c_new()
            self.i2cHandle = i2cHandle
            return i2c_open(i2cHandle!, path.cString(using: .utf8)) == 0
        }
    }
    
    @discardableResult
    public func close() -> Bool {
        if i2cHandle != nil {
            i2c_close(i2cHandle!)
            i2c_fd(i2cHandle!)
            i2cHandle = nil
            return true
        }
        return false
    }
    
    public func tranfer(requests: [Request]) -> [Response] {
        // Request 转为 i2c_msg
        var i2c_msgs: [i2c_msg] = []
        for request in requests {
            var i2c_msg = i2c_msg()
            
            i2c_msg.addr = request.address
            i2c_msg.flags = request.flags.rawValue
            i2c_msg.len = UInt16(request.data.count)
            i2c_msg.buf = UnsafeMutablePointer<UInt8>.allocate(capacity: request.data.count)
            let ptr = request.data.withUnsafeBytes { ptr in
                ptr.withMemoryRebound(to: UInt8.self) { buffer in
                    return buffer.baseAddress!
                }
            }
            memcpy(i2c_msg.buf, ptr, request.data.count)
            
            i2c_msgs.append(i2c_msg)
        }
        // i2c_msg transfer
        let i2c_msgs_ptr = i2c_msgs.withUnsafeMutableBytes { pointer in
            return pointer.baseAddress?.assumingMemoryBound(to: i2c_msg.self)
        }
        let ret = i2c_transfer(i2cHandle!, i2c_msgs_ptr, i2c_msgs.count)
        guard ret == 0 else {
            return []
        }
        
        // i2c_msg 转 Response
        var responses: [Response] = []
        for (index, i2c_msg) in i2c_msgs.enumerated() {
            let request = requests[index]
            
            let response = Response(request: request,
                                    flags: Flag(rawValue: i2c_msg.flags) ?? .NONE,
                                    data: Data(bytes: i2c_msg.buf, count: Int(i2c_msg.len)))
            i2c_msg.buf.deallocate()
            responses.append(response)
        }
        
        
        return responses
    }
    
}

// MARK: - I2C Transfer
public class I2CTransfer {
    public enum RegisterAddress {
        case byte(UInt8)
        case word(UInt16)
        
        public var data: Data {
            switch self {
            case .byte(let uInt8):
                return Data([uInt8])
            case .word(let uInt16):
                return Data([UInt8(uInt16 >> 8), UInt8(uInt16 & 0xFF)])
            }
        }
    }
    
    private let i2c: I2C
    
    public let address: UInt16
    
    deinit {
        self.i2c.close()
    }
    
    public init(chip: I2C.Chip, address: UInt16) {
        self.i2c = I2C(chip: chip)
        self.address = address
        self.i2c.open()
    }
    
    public func readUInt8(register: RegisterAddress) -> UInt8? {
        let request = [
            I2C.Request(address: address, flags: .NONE, data: register.data),
            I2C.Request(address: address, flags: .RD, data: Data([0xff]))
        ]
        let response = i2c.tranfer(requests: request)
        return response[1].data.first
    }
    
    public func writeUInt8(register: RegisterAddress, value: UInt8) {
        let request = [
            I2C.Request(address: address, flags: .NONE, data: register.data),
            I2C.Request(address: address, flags: .NONE, data: Data([value]))
        ]
        let _ = i2c.tranfer(requests: request)
    }
    
    #if false
    public func readInt8(register: RegisterAddress) -> Int8 {
        
    }
    
    public func writeInt8(register: RegisterAddress, value: UInt8) {
        
    }
    
    
    public func readUInt16(register: RegisterAddress) -> UInt16 {
        
    }
    
    public func writeUInt16(register: RegisterAddress, value: UInt16) {
        
    }
    
    public func readInt16(register: RegisterAddress) -> Int16 {
        
    }
    
    public func writeInt16(register: RegisterAddress, value: UInt16) {
        
    }
    
    
    public func readUInt32(register: RegisterAddress) -> UInt32 {
        
    }
    
    public func writeUInt32(register: RegisterAddress, value: UInt32) {
        
    }
    
    public func readInt32(register: RegisterAddress) -> Int32 {
        
    }
    
    public func writeInt32(register: RegisterAddress, value: UInt32) {
        
    }
    
    #endif
}


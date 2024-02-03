//
//  GPIO.swift
//
//
//  Created by Eric Wu on 2024/2/1.
//

import Foundation
import Cperiphery

extension Bool {
    public static var high: Bool { true }
    public static var low: Bool { false }
}

public class GPIO {
    
    public enum Pin {
        case sysfs(Int)
        case cdev(String, Int)
    }
    
    public enum Value {
        case none
        case digital(Bool)
    }
    
    public enum Direction {
        case none
        case input
        case output
        case outputLow
        case outputHigh
        
        init(rawValue: gpio_direction_t) {
            switch rawValue {
            case GPIO_DIR_IN:
                self = .input
            case GPIO_DIR_OUT:
                self = .output
            case GPIO_DIR_OUT_LOW:
                self = .outputLow
            case GPIO_DIR_OUT_HIGH:
                self = .outputHigh
            default:
                self = .none
            }
        }
        
        var rawValue: gpio_direction_t {
            switch self {
            case .none:
                return GPIO_DIR_OUT
            case .input:
                return GPIO_DIR_IN
            case .output:
                return GPIO_DIR_OUT
            case .outputLow:
                return GPIO_DIR_OUT_LOW
            case .outputHigh:
                return GPIO_DIR_OUT_HIGH
            }
        }
    }
    
    public let pin: Pin
    
    private let gpioHandle: UnsafeMutablePointer<gpio_t>
    
    public init(pin: Pin) {
        self.pin = pin
        self.gpioHandle = gpio_new()!
    }
    
    deinit {
        gpio_free(gpioHandle)
    }
}

// MARK: - Ops
extension GPIO {
    public var direction: Direction {
        get {
            var direction: gpio_direction_t = GPIO_DIR_OUT
            if gpio_get_direction(gpioHandle, &direction) == 0 {
                return Direction(rawValue: direction)
            } else {
                return .none
            }
        }
        set {
            gpio_set_direction(gpioHandle, newValue.rawValue)
        }
    }
    
    public func read() -> Value {
        var readBoolValue: Bool = .low
        let ret = gpio_read(gpioHandle, &readBoolValue)
        if ret == 0 {
            return .digital(readBoolValue)
        }
        return .none
    }
    
    @discardableResult
    public func open(direction: Direction = .output) -> Bool {
        switch pin {
        case .sysfs(let line):
            return gpio_open_sysfs(gpioHandle, UInt32(line), direction.rawValue) == 0
        case .cdev(let path, let line):
            return path.cString(using: .utf8)?.withUnsafeBufferPointer { ptr in
                return gpio_open(gpioHandle, ptr.baseAddress, UInt32(line), direction.rawValue) == 0
            } ?? false
        }
    }
    
    @discardableResult
    public func close() -> Bool {
        return gpio_close(gpioHandle) == 0
    }
    
    @discardableResult
    public func write(_ value: Value) -> Bool {
        switch value {
        case .none:
            return false
        case .digital(let bool):
            return gpio_write(gpioHandle, bool) == 0
        }
    }
}

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
        
        var isSysfs: Bool {
            switch self {
            case .sysfs(_):
                return true
            default:
                return false
            }
        }
        
        var isCdev: Bool {
            switch self {
            case .cdev(_, _):
                return true
            default:
                return false
            }
        }
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
    
    public enum Edge {
        case none
        case rising
        case falling
        case both
        
        init(rawValue: gpio_edge_t) {
            switch rawValue {
            case GPIO_EDGE_NONE:
                self = .none
            case GPIO_EDGE_RISING:
                self = .rising
            case GPIO_EDGE_FALLING:
                self = .falling
            case GPIO_EDGE_BOTH:
                self = .both
            default:
                self = .none
            }
        }
        
        var rawValue: gpio_edge_t {
            switch self {
            case .none:
                return GPIO_EDGE_NONE
            case .rising:
                return GPIO_EDGE_RISING
            case .falling:
                return GPIO_EDGE_FALLING
            case .both:
                return GPIO_EDGE_BOTH
            }
        }
    }
    
    public enum Bias {
        case `default`
        case pullUp
        case pullDown
        case disable
        
        init(rawValue: gpio_bias_t) {
            switch rawValue {
            case GPIO_BIAS_DEFAULT:
                self = .default
            case GPIO_BIAS_DISABLE:
                self = .disable
            case GPIO_BIAS_PULL_UP:
                self = .pullUp
            case GPIO_BIAS_PULL_DOWN:
                self = .pullDown
            default:
                self = .default
            }
        }
        
        var rawValue: gpio_bias_t {
            switch self {
            case .default:
                return GPIO_BIAS_DEFAULT
            case .pullUp:
                return GPIO_BIAS_PULL_UP
            case .pullDown:
                return GPIO_BIAS_PULL_DOWN
            case .disable:
                return GPIO_BIAS_DISABLE
            }
        }
    }
    
    public enum Drive {
        case `default`
        case openDrain
        case openSource
        
        init(rawValue: gpio_drive_t) {
            switch rawValue {
            case GPIO_DRIVE_DEFAULT:
                self = .default
            case GPIO_DRIVE_OPEN_DRAIN:
                self = .openDrain
            case GPIO_DRIVE_OPEN_SOURCE:
                self = .openSource
            default:
                self = .default
            }
        }
        
        var rawValue: gpio_drive_t {
            switch self {
            case .default:
                return GPIO_DRIVE_DEFAULT
            case .openDrain:
                return GPIO_DRIVE_OPEN_DRAIN
            case .openSource:
                return GPIO_DRIVE_OPEN_SOURCE
            }
        }
    }
    
    public let pin: Pin
    
    private let gpioHandle: UnsafeMutablePointer<gpio_t>
    
    var gpioEventHandle: ((GPIO) -> Void)?
    
    var fd: Int32 {
        switch pin {
        case .sysfs(_):
            return gpioHandle.pointee.u.sysfs.line_fd
        case .cdev(_, _):
            return gpioHandle.pointee.u.cdev.line_fd
        }
    }
    
    public init(pin: Pin, eventHandle: ((GPIO) -> Void)? = nil) {
        self.pin = pin
        self.gpioHandle = gpio_new()!
        self.gpioEventHandle = eventHandle
    }
    
    deinit {
        close()
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
    
    public var edge: Edge {
        get {
            var edge: gpio_edge_t = GPIO_EDGE_NONE
            gpio_get_edge(gpioHandle, &edge)
            return Edge(rawValue: edge)
        }
        set {
            gpio_set_edge(gpioHandle, newValue.rawValue)
        }
    }
    
    public var drive: Drive {
        get {
            var drive: gpio_drive_t = GPIO_DRIVE_DEFAULT
            gpio_get_drive(gpioHandle, &drive)
            return Drive(rawValue: drive)
        }
        set {
            gpio_set_drive(gpioHandle, newValue.rawValue)
        }
    }
    
    public var bias: Bias {
        get {
            var bias: gpio_bias_t = GPIO_BIAS_DEFAULT
            gpio_get_bias(gpioHandle, &bias)
            return Bias(rawValue: bias)
        }
        set {
            gpio_set_bias(gpioHandle, newValue.rawValue)
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
    
    public func toggle() {
        switch read() {
        case .digital(let currentValue):
            write(.digital(!currentValue))
        default:
            return
        }
    }
     
    public func readEvent() -> (Edge, UInt64)? {
        var edge: gpio_edge_t = GPIO_EDGE_NONE
        var timestamp: UInt64 = 0
        if gpio_read_event(gpioHandle, &edge, &timestamp) == 0 {
            return (Edge(rawValue: edge), timestamp)
        }
        return nil
    }
}

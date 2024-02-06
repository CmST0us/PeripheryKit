//
//  File.swift
//  
//
//  Created by Eric Wu on 2024/2/6.
//

import Foundation
import Cperiphery

public class PWMModulation {
    
    private let workingQueue: DispatchQueue
    
    public var period: TimeInterval = 0.02
    
    public var dutyCycle: TimeInterval = 0
    
    public var frequency: TimeInterval {
        get {
            return 1.0 / period
        }
        set {
            period = 1.0 / newValue
        }
    }
    
    public var polarity: PWM.Polarity = .normal
    
    private var isRunning: Bool = false
    
    private var onHigh: () -> Void
    
    private var onLow: () -> Void
    
    deinit {
        close()
    }
    
    public init(onHigh: @escaping () -> Void, onLow: @escaping () -> Void) {
        workingQueue = DispatchQueue(label: "PWMModulation")
        self.onHigh = onHigh
        self.onLow = onLow
    }
    
    public func open() {
        isRunning = true
        workingQueue.async { [weak self] in
            self?.doModulation()
        }
    }
    
    private func doModulation() {
        guard isRunning else {
            return
        }
        
        let cycleTime = period
        let highTime = cycleTime * dutyCycle
        let lowTime = cycleTime * (1 - dutyCycle)
        polarity == .normal ? onHigh() : onLow()
        Thread.sleep(forTimeInterval: highTime)
        polarity == .normal ? onLow() : onHigh()
        Thread.sleep(forTimeInterval: lowTime)

        workingQueue.async { [weak self] in
            self?.doModulation()
        }
    }
    
    public func close() {
        isRunning = false
    }
}

public class PWM {
    public enum Chip {
        case pwmchip(Int, Int)
        case gpiochip(GPIO.Pin)
        
        public var isPWMChip: Bool {
            switch self {
            case .pwmchip(_, _):
                return true
            default:
                return false
            }
        }
        
        public var isGPIOChip: Bool {
            switch self {
            case .gpiochip(_):
                return true
            default:
                return false
            }
        }
    }
    
    public enum Polarity {
        case normal
        case inversed
        
        init(rawValue: pwm_polarity) {
            switch rawValue {
            case PWM_POLARITY_NORMAL:
                self = .normal
            case PWM_POLARITY_INVERSED:
                self = .inversed
            default:
                self = .normal
            }
        }
        
        var rawValue: pwm_polarity {
            switch self {
            case .normal:
                return PWM_POLARITY_NORMAL
            case .inversed:
                return PWM_POLARITY_INVERSED
            }
        }
    }
    
    public let chip: Chip
    
    private var pwmHandle: OpaquePointer?
    
    private var gpio: GPIO?
    
    private var gpioPWMModulation: PWMModulation?
    
    public init(chip: Chip) {
        self.chip = chip
    }
    
    deinit {
        close()
        if let pwmHandle {
            pwm_free(pwmHandle)
        }
    }
    
    public var period: TimeInterval {
        get {
            switch chip {
            case .pwmchip(_, _):
                var periodValue: Double = 0
                pwm_get_period(pwmHandle!, &periodValue)
                return periodValue
            case .gpiochip(_):
                return gpioPWMModulation?.period ?? 0
            }
        }
        set {
            switch chip {
            case .pwmchip(_, _):
                pwm_set_period(pwmHandle!, newValue)
            case .gpiochip(_):
                gpioPWMModulation?.period = newValue
            }
        }
    }
    
    public var dutyCycle: TimeInterval {
        get {
            switch chip {
            case .pwmchip(_, _):
                var dutyCycleValue: Double = 0
                pwm_get_duty_cycle(pwmHandle!, &dutyCycleValue)
                return dutyCycleValue
            case .gpiochip(_):
                return gpioPWMModulation?.dutyCycle ?? 0
            }
        }
        set {
            switch chip {
            case .pwmchip(_, _):
                pwm_set_duty_cycle(pwmHandle!, newValue)
            case .gpiochip(_):
                gpioPWMModulation?.dutyCycle = newValue
            }
        }
    }
    
    public var frequency: TimeInterval {
        get {
            switch chip {
            case .pwmchip(_, _):
                var frequencyValue: Double = 0
                pwm_get_frequency(pwmHandle!, &frequencyValue)
                return frequencyValue
            case .gpiochip(_):
                return gpioPWMModulation?.frequency ?? 0
            }
        }
        set {
            switch chip {
            case .pwmchip(_, _):
                pwm_set_frequency(pwmHandle!, newValue)
            case .gpiochip(_):
                gpioPWMModulation?.frequency = newValue
            }
        }
    }
    
    public var polarity: Polarity {
        get {
            switch chip {
            case .pwmchip(_, _):
                var polarityValue: pwm_polarity_t = PWM_POLARITY_NORMAL
                pwm_get_polarity(pwmHandle!, &polarityValue)
                return Polarity(rawValue: polarityValue)
            case .gpiochip(_):
                return gpioPWMModulation?.polarity ?? .normal
            }
        }
        set {
            switch chip {
            case .pwmchip(_, _):
                pwm_set_polarity(pwmHandle!, newValue.rawValue)
            case .gpiochip(_):
                gpioPWMModulation?.polarity = newValue
            }
        }
    }
    
    @discardableResult
    public func open() -> Bool {
        switch chip {
        case .pwmchip(let chip, let channel):
            let pwmHandle = pwm_new()
            self.pwmHandle = pwmHandle
            return pwm_open(pwmHandle, UInt32(chip), UInt32(channel)) == 0
        case .gpiochip(let pin):
            let gpio = GPIO(pin: pin)
            self.gpio = gpio
            self.gpioPWMModulation = PWMModulation(onHigh: {
                gpio.write(.digital(true))
            }, onLow: {
                gpio.write(.digital(false))
            })
            self.gpioPWMModulation?.open()
            return gpio.open()
        }
    }
    
    @discardableResult
    public func close() -> Bool {
        switch chip {
        case .pwmchip(_, _):
            return pwm_close(pwmHandle!) == 0
        case .gpiochip(_):
            gpioPWMModulation?.close()
            return gpio?.close() ?? false
        }
    }
    
    @discardableResult
    public func enable() -> Bool {
        switch chip {
        case .pwmchip(_, _):
            return pwm_enable(pwmHandle!) == 0
        case .gpiochip(_):
            return gpio?.write(.digital(polarity == .normal)) ?? false
            
        }
    }
    
    @discardableResult
    public func disable() -> Bool {
        switch chip {
        case .pwmchip(_, _):
            return pwm_disable(pwmHandle!) == 0
        case .gpiochip(_):
            return gpio?.write(.digital(!(polarity == .normal))) ?? false
        }
    }
    
    
}

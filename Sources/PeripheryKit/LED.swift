//
//  LED.swift
//  
//
//  Created by Eric Wu on 2024/2/5.
//

import Foundation

public class LED {
    
    private let gpio: GPIO
    
    private let enableDigital: Bool
    
    public init(pin: GPIO.Pin, enableDigital: Bool = true) {
        self.gpio = GPIO(pin: pin)
        self.enableDigital = enableDigital
        self.gpio.open(direction: enableDigital ? .outputLow : .outputHigh)
    }
    
    public func on() {
        gpio.write(.digital(enableDigital))
    }
    
    public func off() {
        gpio.write(.digital(!enableDigital))
    }
    
    public func toggle() {
        gpio.toggle()
    }
    
    deinit {
        gpio.close()
    }
}

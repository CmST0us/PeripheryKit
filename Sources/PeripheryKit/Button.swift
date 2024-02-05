//
//  Button.swift
//
//
//  Created by Eric Wu on 2024/2/5.
//

import Foundation

public class Button {
    public enum TapEvent {
        case tapDown
        case tapUp
    }
    
    private let gpio: GPIO
    
    private let tapDownEdge: GPIO.Edge
    
    private weak var dispatcher: GPIOEventDispatcher?
    
    public init(pin: GPIO.Pin,
                tapDownEdge: GPIO.Edge,
                bias: GPIO.Bias = .default,
                actionHandler: @escaping (TapEvent) -> Void) {
        self.tapDownEdge = tapDownEdge
        
        self.gpio = GPIO(pin: pin) { gpio in
            if gpio.pin.isSysfs {
                switch gpio.read() {
                case .digital(let value) :
                    if tapDownEdge == .falling &&
                        !value {
                        actionHandler(.tapDown)
                    } else if tapDownEdge == .rising &&
                                value {
                        actionHandler(.tapDown)
                    } else if tapDownEdge == .falling &&
                                value {
                        actionHandler(.tapUp)
                    } else if tapDownEdge == .rising &&
                                !value {
                        actionHandler(.tapDown)
                    }
                default:
                    break
                }
                
            } else {
                guard let event = gpio.readEvent() else {
                    return
                }
                if event.0 == tapDownEdge {
                    actionHandler(.tapDown)
                } else {
                    actionHandler(.tapUp)
                }
            }
        }
        self.gpio.open(direction: .input)
        self.gpio.edge = .both
        self.gpio.bias = bias
    }
    
    public func addToDispatcher(_ dispatcher: GPIOEventDispatcher) {
        dispatcher.addGPIO(gpio)
        self.dispatcher = dispatcher
    }
    
    deinit {
        self.dispatcher?.removeGPIO(self.gpio)
        gpio.close()
    }
}

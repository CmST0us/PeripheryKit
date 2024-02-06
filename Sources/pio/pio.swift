import Foundation
import PeripheryKit
import Cperiphery

@main
struct Pio {
    
    enum LED: CaseIterable {
        case red
        case yellow
        case green
        case blue
        
        var pin: GPIO.Pin {
            switch self {
            case .red:
                return .cdev("/dev/gpiochip3", 1)
            case .yellow:
                return .cdev("/dev/gpiochip3", 2)
            case .green:
                return .cdev("/dev/gpiochip3", 3)
            case .blue:
                return .cdev("/dev/gpiochip3", 8)
            }
        }
    }
    
    enum Button: CaseIterable {
        case sw1
        case sw2
        case sw3
        case sw4
        
        var pin: GPIO.Pin {
            switch self {
            case .sw1:
                return .cdev("/dev/gpiochip3", 18)
            case .sw2:
                return .cdev("/dev/gpiochip3", 9)
            case .sw3:
                return .cdev("/dev/gpiochip3", 10)
            case .sw4:
                return .cdev("/dev/gpiochip0", 15)
            }
        }
    }
     
    static func main() {
        print("pio start")
        
        let eventDispatcher = GPIOEventDispatcher()
        
        let leds = LED.allCases.map { led in
            PeripheryKit.LED(pin: led.pin)
        }
        
        let pwms = leds.map { led in
            let modulation = PWMModulation {
                led.on()
            } onLow: {
                led.off()
            }
            modulation.open()
            return modulation
        }
        
        let motor = PWM(chip: .gpiochip(.cdev("/dev/gpiochip3", 19)))
        motor.open()
        motor.dutyCycle = 0.5
        motor.period = 0.02
        
        let buttons = Button.allCases.enumerated().map { index, button in
            return PeripheryKit.Button(pin: button.pin, tapDownEdge: .falling) { event in
                print("[Button] \(button): \(event)")
                if event == .tapDown {
                    pwms[index].dutyCycle += 0.1
                    
                    if pwms[index].dutyCycle >= 1.0 {
                        pwms[index].dutyCycle = 0.1
                    }
                    
                    motor.dutyCycle += 0.1
                    if motor.dutyCycle >= 0.9 {
                        motor.dutyCycle = 0.1
                    }
                }
            }
        }
        buttons.forEach {
            $0.addToDispatcher(eventDispatcher)
        }
        
        eventDispatcher.start()

        
        RunLoop.main.run()
        
    }
}


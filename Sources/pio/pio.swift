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
    
    struct Music {
        static let twinkle: [(note: Buzzer.Note, value: Int)] = [
            (.C4, 4),
            (.C4, 4),
            (.G4, 4),
            (.G4, 4),

            (.A4, 4),
            (.A4, 4),
            (.G4, 2),

            (.F4, 4),
            (.F4, 4),
            (.E4, 4),
            (.E4, 4),


            (.D4, 4),
            (.D4, 4),
            (.C4, 2),

            (.G4, 4),
            (.G4, 4),
            (.F4, 4),
            (.F4, 4),

            (.E4, 4),
            (.E4, 4),
            (.D4, 2),

            (.G4, 4),
            (.G4, 4),
            (.F4, 4),
            (.F4, 4),

            (.E4, 4),
            (.E4, 4),
            (.D4, 2),

            (.C4, 4),
            (.C4, 4),
            (.G4, 4),
            (.G4, 4),

            (.A4, 4),
            (.A4, 4),
            (.G4, 2),

            (.F4, 4),
            (.F4, 4),
            (.E4, 4),
            (.E4, 4),

            (.D4, 4),
            (.D4, 4),
            (.C4, 2)
        ]
    }
     
    static func main() {
        print("pio start")
#if true
        let eventDispatcher = GPIOEventDispatcher()
        eventDispatcher.start()
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
#endif
        
#if false // Disable buzzer
        var halfStep: Int = 0
        var bpm: Float = 60
        let buzzer = Buzzer(chip: .gpiochip(.cdev("/dev/gpiochip3", 6)), bpm: 100)
        
        DispatchQueue.global().async {
            for _ in 0..<4 {
                buzzer.play(track: Music.twinkle)

                bpm += 40
                buzzer.bpm = bpm

                halfStep += 12
                buzzer.fixedHalfStep = halfStep
                
                Thread.sleep(forTimeInterval: 1)
            }
        }
#endif
        
#if false // I2C AD/DA
        let i2c = I2CTransfer(chip: .i2c("/dev/i2c-2"), address: 0x48)
        while true {
            let value = i2c.readUInt8(register: .byte(0x41))!
            i2c.writeUInt8(register: .byte(0x40), value: value)
            print("read value \(value)")
            Delay.nanosecond(1000000)
        }
#endif
        
        RunLoop.main.run()
    }
}


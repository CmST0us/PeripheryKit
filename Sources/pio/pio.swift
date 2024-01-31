import Foundation
import PeripheryKit

@main
struct Pio {
    static func main() {
        print("pio start")
        let gpio = GPIO(pin: .sysfs(906))
        gpio.open()
        
        for _ in 0..<10 {
            gpio.write(.digital(.high))
            Thread.sleep(forTimeInterval: 1)
            gpio.write(.digital(.low))
        }
        
        gpio.close()
    }
}


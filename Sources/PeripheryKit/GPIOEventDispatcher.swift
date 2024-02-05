//
//  GPIOEventDispatcher.swift
//
//
//  Created by Eric Wu on 2024/2/5.
//

import Foundation

public class GPIOEventDispatcher {
    
    private let workingQueue: DispatchQueue
    
    private var isRunning: Bool = false
    
    public private(set) var gpios: [GPIO] = []
    
    private var gpiosLock: NSLock = NSLock()
    
    private let pollTimeout: Int32
    
    deinit {
        dispose()
    }
    
    public init(pollTimeout: Int32 = 100) {
        workingQueue = DispatchQueue(label: "GPIOEventDispatcher")
        self.pollTimeout = pollTimeout
    }
    
    private func doPoll() {
        guard isRunning else {
            return
        }
        
        gpiosLock.lock()
        
        var fds: [pollfd] = gpios.map { gpio in
            return pollfd(fd: gpio.fd, 
                          events: gpio.pin.isSysfs ? Int16(POLLPRI | POLLERR) : Int16(POLLIN | POLLRDNORM),
                          revents: 0)
        }
        let ret = poll(&fds, nfds_t(fds.count), pollTimeout)
        if ret < 0 {
            isRunning = false
        } else if ret > 0 {
            for i in 0..<fds.count {
                let eventGPIO = gpios[i]
                let eventFd = fds[i]
                
                if eventFd.revents != 0 {
                    if eventGPIO.pin.isSysfs {
                        lseek(eventGPIO.fd, 0, SEEK_SET)
                    }
                    eventGPIO.gpioEventHandle?(eventGPIO)
                }
            }
            
        }
        
        gpiosLock.unlock()
        
        workingQueue.async { [weak self] in
            self?.doPoll()
        }
    }
    
    @discardableResult
    public func start() -> Self {
        isRunning = true
        doPoll()
        return self
    }
    
    @discardableResult
    public func dispose() -> Self {
        isRunning = false
        return self
    }
    
    @discardableResult
    public func addGPIO(_ gpio: GPIO) -> Self {
        gpiosLock.lock()
        defer {
            gpiosLock.unlock()
        }
        gpios.append(gpio)
        return self
    }
    
    @discardableResult
    public func removeGPIO(_ gpio: GPIO) -> Self {
        gpiosLock.lock()
        defer {
            gpiosLock.unlock()
        }
        gpios.removeAll { item in
            ObjectIdentifier(item) == ObjectIdentifier(gpio)
        }
        return self
    }
}

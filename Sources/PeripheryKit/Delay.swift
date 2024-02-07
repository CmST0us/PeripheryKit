//
//  File.swift
//  
//
//  Created by Eric Wu on 2024/2/7.
//

import Foundation
import Cperiphery

public enum Delay {
    public static func nanosecond(_ time: Int) {
        precise_sleep(0, time)
    }
    
    public static func second(_ time: Int) {
        precise_sleep(time, 0)
    }
}

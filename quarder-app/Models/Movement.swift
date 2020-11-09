//
//  Movement.swift
//  quarder-app
//
//  Created by Lou Batier on 05/11/2020.
//

import Foundation

struct Movement {

    enum MovementType {
        case forward,backward,left,right,up,down,rotate_right,rotate_left
    }

    var duration: Double?
    var speed: Float
    var direction: MovementType
    
    func description() -> String {
        if let duration = duration {
            return "\(direction) during \(duration)s at \(speed)"
        } else {
            return "\(direction) at \(speed)"
        }
        
    }
}

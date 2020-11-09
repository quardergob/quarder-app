//
//  MovementManager.swift
//  quarder-app
//
//  Created by Lou Batier on 05/11/2020.
//

import Foundation
import DJISDK

public class MovementManager {
    
    static let instance = MovementManager()
    
    var isTesting:Bool = false
    var sequenceToProceed:[Movement] = [Movement]()
    
    func setSequence(sequence:[Movement]) {
        sequenceToProceed = sequence
    }
    
    func proceedSequence() {
        if sequenceToProceed.count > 0 {
            if let currentMove = sequenceToProceed.first {
                
                sendCommand(currentMove)
                
                if let duration = currentMove.duration {
                    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                        self.stop()
                        if self.sequenceToProceed.count > 0 {
                            self.sequenceToProceed.remove(at: 0)
                            self.proceedSequence()
                        }
                    }
                }
            }
        }
            
        else {
            stop()
            print("Sequence is finished")
        }
    }
    
    func sendCommand(_ movement:Movement) {
        stop()
        
        if (isTesting) {
            print("Mouvement \(movement.description())")
        } else {
            if let mySpark = DJISDKManager.product() as? DJIAircraft {
                switch movement.direction {
                    case .forward,.backward:
                        mySpark.mobileRemoteController?.rightStickVertical = movement.speed
                    case .left,.right:
                        mySpark.mobileRemoteController?.rightStickHorizontal = movement.speed
                    case .up,.down:
                        mySpark.mobileRemoteController?.leftStickVertical = movement.speed
                    case .rotate_left,.rotate_right:
                        mySpark.mobileRemoteController?.leftStickHorizontal = movement.speed
                }
            }
        }
    }
    
    func stop(isFromStopButton: Bool = false) {
        if isFromStopButton {
            if (!sequenceToProceed.isEmpty) {
                sequenceToProceed = []
            }
        }
        
        if let mySpark = DJISDKManager.product() as? DJIAircraft {
            mySpark.mobileRemoteController?.leftStickVertical = 0.0
            mySpark.mobileRemoteController?.leftStickHorizontal = 0.0
            mySpark.mobileRemoteController?.rightStickHorizontal = 0.0
            mySpark.mobileRemoteController?.rightStickVertical = 0.0
        }
    }
    
    func takeOff(callback: @escaping ()->()) {
        if let mySpark = DJISDKManager.product() as? DJIAircraft {
            if let flightController = mySpark.flightController {
                flightController.startTakeoff(completion: { (err) in
                    callback()
                })
            }
        }
    }
    
    func landing(callback: @escaping ()->()) {
        if let mySpark = DJISDKManager.product() as? DJIAircraft {
            if let flightController = mySpark.flightController {
                flightController.startLanding(completion: { (err) in
                    callback()
                })
            }
        }
    }
}

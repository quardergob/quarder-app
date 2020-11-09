//
//  ManualFlightViewController.swift
//  quarder-app
//
//  Created by Lou Batier on 05/11/2020.
//

import UIKit
import DJISDK

class ManualFlightViewController: UIViewController {

    var movementManager:MovementManager = MovementManager.instance
    var speedConstant:Float = 0.5
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func moveButtonClicked(_ sender: UIButton) {

        // TODO : Refacto this switch
        switch sender.tag {
            case 0:
                movementManager.sendCommand(Movement(speed: speedConstant, direction: .forward))
            case 1:
                movementManager.sendCommand(Movement(speed: -speedConstant, direction: .backward))
            case 2:
                movementManager.sendCommand(Movement(speed: -speedConstant, direction: .left))
            case 3:
                movementManager.sendCommand(Movement(speed: speedConstant, direction: .right))
            case 4:
                movementManager.sendCommand(Movement(speed: speedConstant, direction: .up))
            case 5:
                movementManager.sendCommand(Movement(speed: -speedConstant, direction: .down))
            case 6:
                movementManager.sendCommand(Movement(speed: -speedConstant, direction: .rotate_left))
            case 7:
                movementManager.sendCommand(Movement(speed: speedConstant, direction: .rotate_right))
            default:
                return
        }
        
    }
    
    @IBAction func moveButtonReleased(_ sender: UIButton) {
        movementManager.stop()
    }
    
    @IBAction func stopButtonClicked(_ sender: UIButton) {
        movementManager.stop(isFromStopButton: true)
    }
}

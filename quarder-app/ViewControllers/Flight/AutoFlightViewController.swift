//
//  AutoFlightViewController.swift
//  quarder-app
//
//  Created by Lou Batier on 05/11/2020.
//

import UIKit

class AutoFlightViewController: UIViewController {
    
    var movementManager = MovementManager.instance
    
    var introSequence: [Movement] = [
        Movement(duration: 1.0, speed: 0.3, direction: .forward),
        Movement(duration: 2.0, speed: 0.3, direction: .right),
        Movement(duration: 1.0, speed: -0.3, direction: .left),
        Movement(duration: 2.0, speed: -0.3, direction: .backward)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func intro(_ sender: UIButton) {
        movementManager.setSequence(sequence: introSequence)
        movementManager.proceedSequence()
    }
    
    @IBAction func stopButtonClicked(_ sender: UIButton) {
        movementManager.stop(isFromStopButton: true)
    }
}

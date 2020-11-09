//
//  FlightModeViewController.swift
//  quarder-app
//
//  Created by Lou Batier on 05/11/2020.
//

import UIKit
import DJISDK

class FlightModeViewController: UIViewController {

    var movementManager:MovementManager = MovementManager.instance
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func landingButtonClicked(_ sender: UIButton) {
        movementManager.landing { () in
            // "C'est mieux quand ça s'arrête n'est-ce pas ?"
            // "Désolé je suis un peu bruyant, ça faisait un moment que je n'avais pas volé"
            // Combien de fois il se pose pendant la soutenance ? Un phrase différente à chaque fois ?
            print("je viens d'atterir")
        }
    }
    
    @IBAction func takeOffButtonClicked(_ sender: UIButton) {
        movementManager.takeOff { () in
            // "Drominique prêt à agir"
            print("je suis prêt à bouger")
        }
    }
}

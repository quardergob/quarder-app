//
//  UIViewControllerExtensions.swift
//  quarder-app
//
//  Created by Lou Batier on 20/10/2020.
//

import UIKit

extension UIViewController {
    func askForDurationAndSpeed(callBack:@escaping (Float,Float)->()) {
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField { (txt) in
            txt.placeholder = "Speed"
        }
        ac.addTextField { (txt) in
            txt.placeholder = "Duration"
        }

        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned ac] _ in
            if let speedTxt = ac.textFields![0].text,
                let durationTxt = ac.textFields![1].text,
                let speed = Float(speedTxt),
                let duration = Float(durationTxt) {
            
                callBack(speed,duration)
            }
            
        }

        ac.addAction(submitAction)

        present(ac, animated: true)
    }
    
    func askForDurationSpeedAndHeading(callBack:@escaping (Float,Float,Float)->()) {
           let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
           ac.addTextField { (txt) in
               txt.placeholder = "Speed"
           }
           ac.addTextField { (txt) in
               txt.placeholder = "Duration"
           }
        
           ac.addTextField { (txt) in
                txt.placeholder = "Heading"
            }

           let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned ac] _ in
               if let speedTxt = ac.textFields![0].text,
                   let durationTxt = ac.textFields![1].text,
                    let headingTxt = ac.textFields![2].text,
                   let speed = Float(speedTxt),
                   let duration = Float(durationTxt),
                    let heading = Float(headingTxt){
               
                   callBack(speed,duration,heading)
               }
               
           }

           ac.addAction(submitAction)

           present(ac, animated: true)
       }
}

//
//  delay.swift
//  quarder-app
//
//  Created by Lou Batier on 20/10/2020.
//

import UIKit

func delay(_ delay:Float, closure:@escaping ()->()) {
    let when = DispatchTime.now() + Double(delay)
    DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
}

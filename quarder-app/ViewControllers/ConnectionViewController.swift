//
//  ViewController.swift
//  SparkPerso
//
//  Created by AL on 14/01/2018.
//  Copyright © 2018 AlbanPerli. All rights reserved.
//

import UIKit
import DJISDK

class ConnectionViewController: UIViewController {
    
    @IBOutlet weak var sparkConnectionStateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        DJISDKManager.keyManager()?.stopAllListening(ofListeners: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func connectionButtonClicked(_ sender: UIButton) {
        trySparkConnection()
    }
    
}


// SPARK CONNECTION
extension ConnectionViewController {
    func trySparkConnection() {
        
        guard let connectedKey = DJIProductKey(param: DJIParamConnection) else {
            NSLog("Error creating the connectedKey")
            return;
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            DJISDKManager.keyManager()?.startListeningForChanges(on: connectedKey, withListener: self, andUpdate: { (oldValue: DJIKeyedValue?, newValue : DJIKeyedValue?) in
                if let newVal = newValue {
                    if newVal.boolValue {
                         DispatchQueue.main.async {
                            self.productConnected()
                        }
                    }
                }
            })
            DJISDKManager.keyManager()?.getValueFor(connectedKey, withCompletion: { (value:DJIKeyedValue?, error:Error?) in
                if let unwrappedValue = value {
                    if unwrappedValue.boolValue {
                        DispatchQueue.main.async {
                            self.productConnected()
                        }
                    }
                }
            })
        }
    }
    
   
    
    func productConnected() {
        guard let newProduct = DJISDKManager.product() else {
            NSLog("Product is connected but DJISDKManager.product is nil -> something is wrong")
            return;
        }
     
        if let model = newProduct.model {
            self.sparkConnectionStateLabel.text = "\(model) is connected \n"
            Spark.instance.airCraft = DJISDKManager.product() as? DJIAircraft
            
        }
        
        newProduct.getFirmwarePackageVersion{ (version:String?, error:Error?) -> Void in
            
            if let _ = error {
                self.sparkConnectionStateLabel.text = self.sparkConnectionStateLabel.text! + "Firmware Package Version: \(version ?? "Unknown")"
            }else{
                
            }
            
            print("Firmware package version is: \(version ?? "Unknown")")
        }
        
    }
    
    func productDisconnected() {
        self.sparkConnectionStateLabel.text = "Disconnected"
        print("Disconnected")
    }
}


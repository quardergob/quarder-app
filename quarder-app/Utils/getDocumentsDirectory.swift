//
//  getDocumentsDirectory.swift
//  quarder-app
//
//  Created by Lou Batier on 20/10/2020.
//

import UIKit

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let documentsDirectory = paths[0]
    return documentsDirectory
}

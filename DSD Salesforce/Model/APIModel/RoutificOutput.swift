//
//  RoutificOutput.swift
//  DSDConnect
//
//  Created by iOS Developer on 3/16/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import Foundation

class RoutificOutput {

    var status = ""
    var solution: RoutificSolution?

    init(json: JSON) {
        status = json["status"].stringValue
        solution = RoutificSolution(json: json["solution"])
    }
    
}

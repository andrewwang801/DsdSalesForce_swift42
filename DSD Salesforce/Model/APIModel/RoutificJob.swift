//
//  RoutificJob.swift
//  DSDConnect
//
//  Created by iOS Developer on 3/16/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import Foundation

class RoutificJob: RoutificErrorResponse {
    var job_id = ""

    override init(json: JSON) {
        super.init(json: json)
        job_id = json["job_id"].stringValue
    }
}

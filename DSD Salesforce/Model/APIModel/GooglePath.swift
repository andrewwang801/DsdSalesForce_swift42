//
//  GooglePath.swift
//  DSDConnect
//
//  Created by iOS Developer on 12/12/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit

class GooglePath {

    class Distance {

        var text = ""
        var value: Int64 = 0

        init() {

        }
        init(json: JSON) {
            text = json["text"].stringValue
            value = json["value"].int64Value
        }
    }

    class Duration {

        var text = ""
        var value: Int64 = 0

        init() {

        }
        init(json: JSON) {
            text = json["text"].stringValue
            value = json["value"].int64Value
        }
    }

    class Location {

        var lat: Double = 0
        var lng: Double = 0

        init() {

        }
        init(json: JSON) {
            lat = json["lat"].doubleValue
            lng = json["lng"].doubleValue
        }
    }

    class Leg {

        var distance = Distance()
        var duration = Duration()
        var end_location = Location()
        var start_location = Location()
        var steps = [Leg]()

        init() {

        }
        init(json: JSON) {
            distance = Distance(json: json["distance"])
            duration = Duration(json: json["duration"])
            end_location = Location(json: json["end_location"])
            start_location = Location(json: json["start_location"])
            if let stepJSONArray = json["steps"].array {
                var newStepArray = [Leg]()
                for stepJSON in stepJSONArray {
                    let step = Leg(json: stepJSON)
                    newStepArray.append(step)
                }
                steps = newStepArray
            }
        }
    }

    class Route {

        var legs = [Leg]()

        init() {

        }
        init(json: JSON) {
            if let legJSONArray = json["legs"].array {
                var newLegArray = [Leg]()
                for legJSON in legJSONArray {
                    let leg = Leg(json: legJSON)
                    newLegArray.append(leg)
                }
                legs = newLegArray
            }
        }
    }

    var routes = [Route]()

    init() {

    }
    init(json: JSON) {
        if let routeJSONArray = json["routes"].array {
            var newRouteArray = [Route]()
            for routeJSON in routeJSONArray {
                let route = Route(json: routeJSON)
                newRouteArray.append(route)
            }
            routes = newRouteArray
        }
    }

}

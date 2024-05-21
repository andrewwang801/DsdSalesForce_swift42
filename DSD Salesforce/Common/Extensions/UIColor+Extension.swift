//
//  UIColor+Extension.swift
//  MyTaxPal
//
//  Created by iOS Developer on 5/21/16.
//  Copyright © 2016 Q-Scope. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    var redValue: CGFloat {
        let components = self.cgColor.components
        return components![0]
    }
    
    var greenValue: CGFloat {
        let components = self.cgColor.components
        return components![1]
    }
    
    var blueValue: CGFloat {
        let components = self.cgColor.components
        return components![2]
    }
    
    var alphaValue: CGFloat {
        return self.cgColor.alpha
    }
}

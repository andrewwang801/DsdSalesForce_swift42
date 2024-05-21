//
//  UIView+Extension.swift
//  iRis
//
//  Created by iOS Developer on 2/4/16.
//  Copyright © 2016 Q-Scope. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    
    func setTitleForAllState(title: String) {
        self.setTitle(title, for: .normal)
        self.setTitle(title, for: .highlighted)
        self.setTitle(title, for: .selected)
        self.setTitle(title, for: .disabled)
    }

    func setImageForAllState(image: UIImage?) {
        self.setImage(image, for: .normal)
        self.setImage(image, for: .highlighted)
        self.setImage(image, for: .selected)
        self.setImage(image, for: .disabled)
    }
}

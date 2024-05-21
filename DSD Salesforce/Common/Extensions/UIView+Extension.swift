//
//  UIView+Extension.swift
//  MyTaxPal
//
//  Created by iOS Developer on 2/4/16.
//  Copyright © 2016 Q-Scope. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func setCornerRadius(cornerRadius:CGFloat, borderWidth:CGFloat, borderColor:UIColor) {
        self.layer.cornerRadius = cornerRadius
        self.layer.borderWidth = borderWidth;
        self.layer.borderColor = borderColor.cgColor;
        self.layer.masksToBounds = true;
    }
    
    func setTopCornerRadius(cornerRadius:CGFloat, borderWidth:CGFloat, borderColor:UIColor) {
        
        let maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [UIRectCorner.topLeft, UIRectCorner.topRight], cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
        
        let borderLayer = CAShapeLayer()
        borderLayer.frame = self.bounds
        borderLayer.path = maskPath.cgPath
        borderLayer.lineWidth = borderWidth
        borderLayer.strokeColor = borderColor.cgColor
        borderLayer.fillColor = UIColor.clear.cgColor
        
        self.layer.addSublayer(borderLayer)
    }
    
    func setShadow(offset: CGSize, radius: CGFloat, opacity: Float, color: UIColor) {
        self.clipsToBounds = false
        self.layer.shadowOffset = offset
        self.layer.shadowRadius = radius
        self.layer.shadowOpacity = opacity
        self.layer.shadowColor = color.cgColor
    }
    
    func fitChildView(childView: UIView) {
        
        self.addConstraint(NSLayoutConstraint(item: childView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: childView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: childView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: childView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0))
    }
    
    func fitChildView(childView: UIView, topMargin: CGFloat, leftMargin: CGFloat, rightMargin: CGFloat, bottomMargin: CGFloat) {
        
        self.addConstraint(NSLayoutConstraint(item: childView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: topMargin))
        self.addConstraint(NSLayoutConstraint(item: childView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: bottomMargin))
        self.addConstraint(NSLayoutConstraint(item: childView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: leftMargin))
        self.addConstraint(NSLayoutConstraint(item: childView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: rightMargin))
    }
}

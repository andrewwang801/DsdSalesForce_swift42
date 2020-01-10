//
//  SignatureVC.swift
//  Codigo
//
//  Created by iOS Developer on 2/21/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit
import IBAnimatable
import CoreGraphics

class SignatureVC: UIViewController {

    @IBOutlet weak var saveButton: AnimatableButton!
    @IBOutlet weak var signatureView: AnimatableView!
    @IBOutlet weak var signatureImageView: UIImageView!
    @IBOutlet weak var templateImageView: UIImageView!
    @IBOutlet weak var exitButton: AnimatableButton!
    @IBOutlet weak var clearButton: AnimatableButton!
    
    var lastPoint = CGPoint.zero
    var lineWidth: CGFloat = 3.0
    var dismissHandler: ((UIImage) -> ())?
    var swiped = false
    var touched = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        disableAccept()
        initUI()
    }
    
    func initUI() {
        exitButton.setTitleForAllState(title: L10n.exit())
        saveButton.setTitleForAllState(title: L10n.save())
        clearButton.setTitleForAllState(title: L10n.clear())
    }

    func enableAccept() {
        saveButton.isEnabled = true
        saveButton.alpha = 1
    }

    func disableAccept() {
        saveButton.isEnabled = false
        saveButton.alpha = 0.5
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let pt = touch.location(in: signatureView)
        if signatureView.bounds.contains(pt) == false {
            return
        }
        lastPoint = pt
        touched = true
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 6
        if touched == false {
            return
        }

        swiped = true
        if let touch = touches.first  {
            let currentPoint = touch.location(in: signatureView)
            drawLine(fromPoint: lastPoint, toPoint: currentPoint)
            enableAccept()

            // 7
            lastPoint = currentPoint
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

        if touched == false {
            return
        }

        if swiped == false  {
            // draw a single point
            drawLine(fromPoint: lastPoint, toPoint: lastPoint)
        }

        // Merge tempImageView into mainImageView
        UIGraphicsBeginImageContext(signatureView.frame.size)
        signatureImageView.image?.draw(in: CGRect(x: 0, y: 0, width: signatureView.frame.size.width, height: signatureView.frame.size.height), blendMode: .normal, alpha: 1.0)
        templateImageView.image?.draw(in: CGRect(x: 0, y: 0, width: signatureView.frame.size.width, height: signatureView.frame.size.height), blendMode: .normal, alpha: 1.0)
        signatureImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        templateImageView.image = nil
        swiped = false
        touched = false

    }

    func drawLine(fromPoint: CGPoint, toPoint: CGPoint) {

        UIGraphicsBeginImageContext(signatureView.bounds.size)
        let context = UIGraphicsGetCurrentContext()
        templateImageView.image?.draw(in: CGRect(x: 0, y: 0, width: signatureView.frame.size.width, height: signatureView.frame.size.height))

        // 2
        context?.move(to: CGPoint(x: fromPoint.x, y: fromPoint.y))
        context?.addLine(to: CGPoint(x: toPoint.x, y: toPoint.y))

        // 3
        context?.setLineCap(.round)
        context?.setLineWidth(lineWidth)
        context?.setStrokeColor(UIColor.black.cgColor)
        //context?.setBlendMode(.normal)

        // 4
        context?.strokePath()

        // 5
        templateImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        templateImageView.alpha = 1.0
        UIGraphicsEndImageContext()
    }

    @IBAction func onBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func onClear(_ sender: Any) {
        templateImageView.image = nil
        signatureImageView.image = nil
        disableAccept()
    }

    @IBAction func onSave(_ sender: Any) {
        let image = signatureImageView.image
        if image == nil {
            return
        }
        self.dismiss(animated: true) {
            self.dismissHandler?(image!)
        }
    }

}

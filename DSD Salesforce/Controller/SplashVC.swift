//
//  SplashVC.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 3/15/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit

class SplashVC: UIViewController {

    @IBOutlet weak var splashImage: UIImageView!

    var hasPresented = false
    var firstAnimationStepPassed = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        splashImage.alpha = 0
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SplashVC.onTapMainView))
        view.addGestureRecognizer(tapGesture)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        //startMain()
        startAnimation()
    }

    func startAnimation() {
        splashImage.alpha = 0.0
        UIView.animate(withDuration: 1.0, animations: {
            self.splashImage.alpha = 0.0
        }) { (completed) in

            if completed == true && self.hasPresented == false {

                self.firstAnimationStepPassed = true

                UIView.animate(withDuration: 4.0, animations: {
                    self.splashImage.alpha = 1.0
                }, completion: { (completed) in
                    if completed == true && self.hasPresented == false {
                        UIView.animate(withDuration: 1.0, animations: {
                            self.splashImage.alpha = 1.0
                        }, completion: { (completed) in
                            if completed == true && self.hasPresented == false {
                                UIView.animate(withDuration: 2.0, animations: {
                                    self.splashImage.alpha = 0.0
                                }, completion: { (completed) in
                                    self.openLogin()
                                })
                            }
                        })
                    }
                })
            }
        }
    }

    func openLogin() {

        if self.hasPresented == true {
            return
        }

        DispatchQueue.main.async {
            let loginVC = UIViewController.getViewController(storyboardName: "Main", storyboardID: "LoginVC") as! LoginVC
            loginVC.setDefaultModalPresentationStyle()
            self.present(loginVC, animated: true, completion: nil)

            self.hasPresented = true
        }
    }

    @objc func onTapMainView() {

        if self.firstAnimationStepPassed == false {
            return
        }

        openLogin()
    }

}

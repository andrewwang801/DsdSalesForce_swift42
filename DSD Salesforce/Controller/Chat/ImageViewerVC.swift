//
//  ImageViewerVC.swift
//  iRis
//
//  Created by iOS Developer on 7/30/16.
//  Copyright © 2016 Q-Scope. All rights reserved.
//

import UIKit
import MediaPlayer

class ImageViewerVC: UIViewController {

    @IBOutlet weak var imageConstraintTop: NSLayoutConstraint!
    @IBOutlet weak var imageConstraintRight: NSLayoutConstraint!
    @IBOutlet weak var imageConstraintBottom: NSLayoutConstraint!
    @IBOutlet weak var imageConstraintLeft: NSLayoutConstraint!
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var pictureScrollView: UIScrollView!
    
    var image: UIImage?
    var lastZoomScale: CGFloat = -1

    enum DismissOption {
        case choose
        case close
    }

    var dismissHandler: ((DismissOption, ImageViewerVC) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initUI()
    }

    func initUI() {
            
        pictureScrollView.delegate = self
        let originalBounds = UIScreen.main.bounds
        pictureScrollView.frame = CGRect(x:0, y:0, width:originalBounds.size.width, height:originalBounds.size.height-44)
        
        updateZoom()
        updateConstraints()
    
        pictureImageView.image = image
    }
    
    // Update zoom scale and constraints with animation.
    @available(iOS 8.0, *)
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.updateZoom()
            }, completion: nil)
    }
    
    // Zoom to show as much image as possible unless image is smaller than the scroll view
    func updateZoom() {
        if let image = self.image {
            var minZoom = min(pictureScrollView.bounds.size.width / image.size.width,
                              pictureScrollView.bounds.size.height / image.size.height)
            
            if minZoom > 1 { minZoom = 1 }
            
            pictureScrollView.minimumZoomScale = minZoom
            
            // Force scrollViewDidZoom fire if zoom did not change
            if minZoom == lastZoomScale { minZoom += 0.000001 }
            
            pictureScrollView.zoomScale = minZoom
            lastZoomScale = minZoom
        }
    }
    
    func updateConstraints() {
        
        if let image = self.image {
            let imageWidth = image.size.width
            let imageHeight = image.size.height
            
            let viewWidth = pictureScrollView.bounds.size.width
            let viewHeight = pictureScrollView.bounds.size.height
            
            // center image if it is smaller than the scroll view
            var hPadding = (viewWidth - pictureScrollView.zoomScale * imageWidth) / 2
            if hPadding < 0 { hPadding = 0 }
            
            var vPadding = (viewHeight - pictureScrollView.zoomScale * imageHeight) / 2
            if vPadding < 0 { vPadding = 0 }
            
            imageConstraintLeft.constant = hPadding
            imageConstraintRight.constant = hPadding
            
            imageConstraintTop.constant = vPadding
            imageConstraintBottom.constant = vPadding
            
            view.layoutIfNeeded()
        }
    }
    /*
    @IBAction func onTakeAnotherButton(_ sender: Any) {
        self.dismiss(animated: true) { 
            self.dismissHandler?(.cancel, self)
        }
    }*/
    
    @IBAction func onClose(_ sender: Any) {
        self.dismiss(animated: true) {
            self.dismissHandler?(.close, self)
        }
    }
}

// MARK: - UIScrollViewDelegate
extension ImageViewerVC: UIScrollViewDelegate {
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateConstraints()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.pictureImageView
    }

}

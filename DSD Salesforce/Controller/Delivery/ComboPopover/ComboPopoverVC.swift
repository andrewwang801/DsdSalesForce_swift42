//
//  ComboPopoverVC.swift
//  MyTaxPal
//
//  Created by iOS Developer on 5/23/16.
//  Copyright © 2017 Q-Scope. All rights reserved.
//

import UIKit

class ComboPopoverVC: UIViewController {

    var selectedTitle: String = ""
    var vaItemArray = [String]()
    var viSelectedIndex: Int = -1
    
    var dismissHandler: ((ComboPopoverVC, Int)->())?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var okButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        cancelButton.setTitleForAllState(title: L10n.cancel())
        okButton.setTitleForAllState(title: L10n.ok())
        titleLabel.text = selectedTitle
        
        mainView.setCornerRadius(cornerRadius: 8.0, borderWidth: 0.0, borderColor: UIColor.clear)
        mainView.setShadow(offset: CGSize(width: 0, height: 0), radius: 2.0, opacity: 0.3, color: UIColor.black)
        
        let itemCount = vaItemArray.count
        
        let viewHeaderHeight: CGFloat = 58.0
        let viewBottomMargin: CGFloat = 68.0
        let minItemCount = 2
        
        let minViewHeight: CGFloat = CGFloat(minItemCount) * kMenuCellHeight + viewHeaderHeight + viewBottomMargin
        let maxViewHeight = UIScreen.main.bounds.height * 0.75
        
        let targetViewHeight: CGFloat = CGFloat(itemCount) * kMenuCellHeight + viewHeaderHeight + viewBottomMargin
        var resultHeight = max(targetViewHeight, minViewHeight)
        resultHeight = min(resultHeight, maxViewHeight)

        heightConstraint.constant = resultHeight
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }

    @IBAction func onClose(_ sender: Any) {
        self.dismiss(animated: true) { 
            self.dismissHandler?(self, -1)
        }
    }
    
    @IBAction func onOK(_ sender: Any) {
        self.dismiss(animated: true) {
            self.dismissHandler?(self, self.viSelectedIndex)
        }
    }
}

extension ComboPopoverVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vaItemArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let liRow = indexPath.row
        let lsItem = vaItemArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ComboCell", for: indexPath) as! ComboCell
        cell.contentLabel!.text = lsItem
        
        if liRow == vaItemArray.count-1 {
            cell.separatorLabel.isHidden = true
        }
        else {
            cell.separatorLabel.isHidden = false
        }
        
        if liRow == viSelectedIndex {
            cell.checkImageView.isHidden = false
        }
        else {
            cell.checkImageView.isHidden = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kMenuCellHeight
    }
}

extension ComboPopoverVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viSelectedIndex = indexPath.row
        tableView.reloadData()
    }
}

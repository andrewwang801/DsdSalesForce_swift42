//
//  MenuComboPopoverVC.swift
//  iRis
//
//  Created by iOS Developer on 5/23/16.
//  Copyright © 2016 Q-Scope. All rights reserved.
//

import UIKit

class MenuComboPopoverVC: UIViewController {

    var menuNamesArray = [String]()
    var viSelectedIndex: Int = -1
    var cellHeight: CGFloat = kPopoverMenuCellHeight
    
    var dismissHandler: ((MenuComboPopoverVC, Int) -> ())?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }

}

extension MenuComboPopoverVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuNamesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        let menuName = menuNamesArray[index]
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuComboCell", for: indexPath) as! MenuComboCell
        cell.contentLabel.text = menuName
        
        // separator line
        if menuNamesArray.count-1 == index {
            cell.separatorLabel.isHidden = true
        }
        else {
            cell.separatorLabel.isHidden = false
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
}

extension MenuComboPopoverVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.dismiss(animated: true) {
            self.dismissHandler?(self, indexPath.row)
        }
    }
}

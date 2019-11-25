//
//  MultiSelectMenuPopoverVC.swift
//  DSD Salesforce
//
//  Created by iOS Developer on 6/11/19.
//  Copyright © 2019 iOS Developer. All rights reserved.
//

import UIKit

class MultiSelectMenuPopoverVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var menuNamesArray = [String]()
    var innerMenuNamesArray = [String]()
    var selectedIndexArray = [Int]()
    var innerSelectedIndexArray = [Int]()
    let kCellHeight: CGFloat = 44.0


    var dismissHandler: ((MultiSelectMenuPopoverVC) -> ())?
    var selectionHandler: ((MultiSelectMenuPopoverVC) -> ())?

    override func viewDidLoad() {
        super.viewDidLoad()

        initData()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.reloadData()
    }

    func initData() {
        updateInnerMenus()
    }

    func updateInnerMenus() {
        innerMenuNamesArray.removeAll()
        innerMenuNamesArray.append(contentsOf: menuNamesArray)
        innerMenuNamesArray.insert("- ALL -", at: 0)

        innerSelectedIndexArray.removeAll()
        if selectedIndexArray.count == 0 {
            innerSelectedIndexArray.append(0)
        }
        else {
            for selectedIndex in selectedIndexArray {
                innerSelectedIndexArray.append(selectedIndex+1)
            }
        }
    }

    func updateSelectedIndexArray() {
        selectedIndexArray.removeAll()
        if innerSelectedIndexArray.firstIndex(of: 0) == nil {
            for innerSelectedIndex in innerSelectedIndexArray {
                selectedIndexArray.append(innerSelectedIndex-1)
            }
        }
    }

    func updateInnerSelectedIndexArrayIfNeeded() {
        if innerSelectedIndexArray.count == 0 {
            innerSelectedIndexArray.append(0)
        }
        else {
            if innerSelectedIndexArray.count == innerMenuNamesArray.count-1 {
                /*
                if innerSelectedIndexArray.firstIndex(of: 0) == nil {
                    innerSelectedIndexArray.removeAll()
                    innerSelectedIndexArray.append(0)
                }*/
            }
        }
    }

    func getHeight() -> CGFloat {
        return CGFloat(innerMenuNamesArray.count)*kCellHeight
    }

}

extension MultiSelectMenuPopoverVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return innerMenuNamesArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        let menuName = innerMenuNamesArray[index]
        let cell = tableView.dequeueReusableCell(withIdentifier: "MultiSelectMenuCell", for: indexPath) as! MultiSelectMenuCell
        cell.contentLabel.text = menuName

        if let _ = innerSelectedIndexArray.firstIndex(of: index) {
            cell.checkImageView.isHidden = false
        }
        else {
            cell.checkImageView.isHidden = true
        }

        // separator line
        if innerMenuNamesArray.count-1 == index {
            cell.separatorLabel.isHidden = true
        }
        else {
            cell.separatorLabel.isHidden = false
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kCellHeight
    }
}

extension MultiSelectMenuPopoverVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let index = indexPath.row
        if let _index = innerSelectedIndexArray.firstIndex(of: index) {
            innerSelectedIndexArray.remove(at: _index)
        }
        else {
            innerSelectedIndexArray.append(index)
            if index == 0 {
                innerSelectedIndexArray.removeAll()
            }
            else {
                if let _index = innerSelectedIndexArray.firstIndex(of: 0) {
                    innerSelectedIndexArray.remove(at: _index)
                }
            }
        }

        updateInnerSelectedIndexArrayIfNeeded()
        updateSelectedIndexArray()
        self.selectionHandler?(self)

        tableView.reloadData()
    }
}

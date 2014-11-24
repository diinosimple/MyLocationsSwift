//
//  CategoryPickerViewController.swift
//  MyLocationsSwift
//
//  Created by Iino Daisuke on 2014/11/08.
//  Copyright (c) 2014年 Iino Daisuke. All rights reserved.
//

import Foundation
import UIKit
class CategoryPickerViewController: UITableViewController {
    var selectedCategoryName = ""

    let categories = [
        "No Category",
        "Apple Store",
        "Bar",
        "Bookstore",
        "Club",
        "Grocery Store",
        "Historic Building",
        "House",
        "Icecream Vendor",
        "Landmark",
        "Park"]
    
    var selectedIndexPath = NSIndexPath()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = UIColor.blackColor()
        tableView.separatorColor = UIColor(white: 1.0, alpha: 0.2)
        tableView.indicatorStyle = .White
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell,
            forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.blackColor()
        cell.textLabel.textColor = UIColor.whiteColor()
        cell.textLabel.highlightedTextColor = cell.textLabel.textColor
        let selectionView = UIView(frame: CGRect.zeroRect)
        selectionView.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
        cell.selectedBackgroundView = selectionView
    }
    
    // MARK: - UITableViewDataSource
    override func tableView(tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell
        let categoryName = categories[indexPath.row]
        cell.textLabel.text = categoryName
        
        if categoryName == selectedCategoryName {
            cell.accessoryType = .Checkmark
            selectedIndexPath = indexPath
        } else {
            cell.accessoryType = .None
        }
        return cell
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(tableView: UITableView,
        didSelectRowAtIndexPath indexPath: NSIndexPath) {

        if indexPath.row != selectedIndexPath.row {
            if let newCell = tableView.cellForRowAtIndexPath(indexPath) {
                newCell.accessoryType = .Checkmark
            }
            if let oldCell = tableView.cellForRowAtIndexPath( selectedIndexPath) {
                oldCell.accessoryType = .None
            }
            selectedIndexPath = indexPath
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PickedCategory" {
            let cell = sender as UITableViewCell
            if let indexPath = tableView.indexPathForCell(cell) {
                println("CategoryName = \(categories[indexPath.row])")
                selectedCategoryName = categories[indexPath.row]
            }
        }
    }
}
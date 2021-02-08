//
//  CategoryPickerViewController.swift
//  MyLocations
//
//  Created by Wm. Zazeckie on 2/7/21.
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
    
    var selectedIndexPath = IndexPath()
    
    
    // viewDidLoad Override Method
    // loops through the array of categories, comparing each category to selectedCategoryName
    // match = creating an index-path object and is stored inside in the selectedIndexPath variable
    // loop keeps going until it finds a match and breaks
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // this loops finds the index
        for i in 0..<categories.count {
            if categories[i]  == selectedCategoryName {
                selectedIndexPath = IndexPath (row: i, section: 0)
                break
            }
        }
    }
    
    
    // MARK:- Table View Delegates
    
    // tableView section:
    
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int{
        return categories.count
    }
    
    
    // tableView cellForRowAt indexPath:
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell",
                                                 for: indexPath)
        
        let categoryName = categories[indexPath.row]
        cell.textLabel!.text = categoryName
        
        if categoryName == selectedCategoryName {
            cell.accessoryType = .checkmark
        }
        else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    
    // tableView didSelectRowAt indexPath:
    // we know the row number at this point, this method removes the checkmark whenanother row is tapped
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != selectedIndexPath.row {
            if let newCell = tableView.cellForRow(at: indexPath) {
                newCell.accessoryType = .checkmark
            }
            
            if let oldCell = tableView.cellForRow(at: selectedIndexPath){
                oldCell
                    .accessoryType = .none
            }
            
            selectedIndexPath = indexPath
            
        }
    }
    
    
    // MARK:- Navigation
    // using the idenitifer "PickedCategory" for the unwind segue, this method puts the corresponding category name into the selectedCategoryName property
    override func prepare(for segue: UIStoryboardSegue,
                           sender: Any?) {
        if segue.identifier == "PickedCategory" {
            let cell = sender as! UITableViewCell
            if let indexPath = tableView.indexPath(for: cell) {
                selectedCategoryName = categories[indexPath.row]
            }
        }
    }
    
}

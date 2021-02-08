//
//  LocationDetailsViewController.swift
//  MyLocations
//
//  Created by Wm. Zazeckie on 2/7/21.
//

import Foundation
import UIKit

import CoreLocation // importing to use CLPlacemark and CLLocationCoordinate2D

 // a private global constant. creating an object then setting values for its properties in one go via a closure
private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()


class LocationDetailsViewController: UITableViewController {
    
    // outlets
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    // properties
    var coordinate = CLLocationCoordinate2D (latitude: 0,  // <- a structure (struct) that has the properties latitude and longitude
                                             longitude: 0)
    var placemark: CLPlacemark?
    
    
    // stores the chosen category
    var categoryName = "No Category"
    
    // MARK:- Actions
    
    // upon pressing sub view hudView is displayed on screen and is delayed by .6 before going back to previous view, where the subview is removed off the screen.
    
    @IBAction func done() {
        let hudView = HudView.hud(inView: navigationController!.view, animated: true)
        
        hudView.text = "Tagged"
        
        // closing the screen, telling the app to wait a few seconds before executing function afterDelay from Functions.swift
        afterDelay(0.6)  {
            hudView.hide()
            self.navigationController?.popViewController(animated: true)
        }
        
        
    }
    // this action method goes back to the previous view
    @IBAction func cancel() {
        navigationController?.popViewController(animated: true)
    }
    
    // this action goes back to the previous view while changing and recording the selected category
    @IBAction func categoryPickerDidPickCategory (_ segue: UIStoryboardSegue) {
        
        let controller = segue.source as! CategoryPickerViewController
        categoryName = controller.selectedCategoryName
        categoryLabel.text = categoryName
    }
    
   
    
    
    
    // MARK:- Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        descriptionTextView.text = ""
        categoryLabel.text = categoryName
        
        latitudeLabel.text = String(format: "%.8f",
                                    coordinate.latitude)
        longitudeLabel.text = String(format: "%.8f",
                                     coordinate.longitude)
        
        if let placemark = placemark {
            addressLabel.text = string(from: placemark)
        }
        else {
            addressLabel.text = "No Address Found"
        }
        
        dateLabel.text = format(date: Date())
        
        // Hides the keyboard when tapping anywhere but the text view using the UITapGestureRecognizer, which recognizes simple taps
        let gestureRecognizer = UITapGestureRecognizer(target: self,
                                                       action: #selector(hideKeyboard))
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)
    }
    
    
    
    // MARK:- Helper Methods
    
    
    // formatting the placemark + country into one string named text
    
    func string(from placemark: CLPlacemark) -> String {
        var text = ""
        
        if let s = placemark.subThoroughfare {
            text += s + " "
        }
        if let s = placemark.thoroughfare {
            text += s + " "
        }
        if let s = placemark.locality {
            text += s + ", "
        }
        if let s = placemark.administrativeArea {
            text += s + " "
        }
        if let s = placemark.postalCode {
            text += s + ", "
        }
        if let s = placemark.country {
            text += s
        }
        return text
        
    }
    
    // turns the Date into a String and returns it
    
    func format(date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    // only hiding the keyboard if the section tapped is not 0, row 0
    
    @objc func hideKeyboard(_ gestureRecognizer: UIGestureRecognizer) {
        let point = gestureRecognizer.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        if indexPath != nil && indexPath!.section == 0
            && indexPath!.row == 0 {
            return
        }
        descriptionTextView.resignFirstResponder()
    }
    
    
    
    
    // MARK:- Navigation
    // unwind segue 
    override func prepare (for segue: UIStoryboardSegue,
                           sender: Any?) {
        if segue.identifier == "PickCategory" {
            let controller = segue.destination as!
                            CategoryPickerViewController
            controller.selectedCategoryName = categoryName
            
        }
    }
    
    
    // MARK:- Table View Delegates
    
    // this method makes sure that when the user taps in the first section and also on the first row give input focus to the text view
    override func tableView(_ tableView: UITableView,
                            willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 0 || indexPath.section == 1{
            return indexPath
        }
        else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0{
            descriptionTextView.becomeFirstResponder()
        }
    }
    
    
}

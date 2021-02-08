//
//  ViewController.swift
//  MyLocations
//
//  Created by Wm. Zazeckie on 2/6/21.
//

import UIKit
// Adding the Core Location framework to the project
import CoreLocation

class CurrentLocationViewController: UIViewController, // making the view controller conform the CLLocationManagerDelegate protocol
                                     CLLocationManagerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()
        // Do any additional setup after loading the view.
    }
    
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var getButton: UIButton!
    
    
    // Properties
    
    let locationManager = CLLocationManager()
    // instance variable , has ? because it is possible to not have a location
    var location: CLLocation?
    
    // error instance variables
    var updatingLocation = false
    var lastLocationError: Error?
    
    
    // properties being used for reverse geocoding
   
    let geocoder = CLGeocoder()  // CLGeocoder is the object that will perform the geocoding and CLPlacemark is the object that contains the address results.
    
    var placemark: CLPlacemark? // is optional since it will have no value when there is no location yet, or when the location does not correspond to a street address
    
    var performingReverseGeocoding = false // becomes true when a geocoding operation is taking place
    
    var lastGeocodingError: Error? // this will contain an error object if something went wrong or nil if there is no error
    
    // Second fix instance variable
    var timer: Timer?
    
    
    // MARK:- Actions
    @IBAction func getLocation(){
        
        
        
        // asking for permission
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        // ===================
        // Checking to see whether or not to show user pop up regarding enabling location services
        if authStatus == .denied || authStatus == .restricted {
            showLocationServicesDeniedAlert()
            return
        }
        
        
        // if user has indeed turned on location services then execute the following methods
       // using the updatingLocation flag to determine was state the app is in
        if updatingLocation {
            stopLocationManager()
        } else {
            location = nil
            lastLocationError = nil
            placemark = nil
            lastGeocodingError = nil
            startLocationManager()
        }
        updateLabels()
        
    }
    
    // Our delegate methods for the location manager
    
    // MARK:- CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error){
        print("didFailWithError \(error.localizedDescription)")
        
        // this eror means the location manager was unable to obtain a location right now, it might need another second or so to get an uplink to the GPS satellite.
        if (error as NSError).code ==
            CLError.locationUnknown.rawValue{
            return
        }
        // If there is a serious error it is stroed in lastLocationError, then later we have the ability to look up the error
        // lastLocaitonError is an optional since an error might not occur
        
        lastLocationError = error
        
        // If unable to obtain a location, tells the location manager to stop, to conserve battery power
        // to try and obtain a location again, the user will oress Get My Location Button again
        stopLocationManager()
        
        // Update labels method is executed
        updateLabels()
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        
        let newLocation = locations.last!
        print ( "didUpdateLocations \(newLocation)")
        
        // 1   If the given location object was determined too long ago ( 5 seconds ago in this case) then this is a cached result
        if newLocation.timestamp.timeIntervalSinceNow <  -5 {
            return
        }
        
        // 2  determines if these new readings are more accurate than previous ones, using horizontalAccuracy of the location object.
             // sometimes locations may have a horizontalAccuracy that is less than 0, which then these measurements are invalid and should be ignored
        if newLocation.horizontalAccuracy < 0 {
            return
        }
        
        // NEW #1 calculates the distance between the new and previous readings, we can use this distance to measure if our location updates are still improving
        var distance = CLLocationDistance(
            Double.greatestFiniteMagnitude)
        if let location = location {
            distance = newLocation.distance(from: location)
        }
    
        
        
        
        
        // 3  determining if the new reading is more useful than the previous one. Generally speaking, Core Location starts out with a fairly inaccurate reading and then gives you more and more as time passes,
           // thus this if statement checks if location! is greater than the new reading ( newLocation ), a larger accuracy value means less accurate. PG 593
        if location == nil || location!.horizontalAccuracy >
                              newLocation.horizontalAccuracy { // the app looks at location!.horizontalAccuracy only when location is guarenteed ot be non-nil.
            
            // 4  clearing out any previous error and storing the new CLLocation object into the location variable
            lastLocationError = nil
            location = newLocation
              
            // 5       if the new location's accuracy is equal to or better than the desired accuracy, then stop asking the location manager for updates.
                    // when starting the location manager in startLocationManager(), the desired accuracy is set to 10 meters ( kCLLocationAccuracyNearestTenMeters ), which is good enough for this app
            
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
                print("*** We're done!")
                stopLocationManager()
                
                
                // NEW #2   stopping the location manager, forcing a reverse geocoding for the final location, even if the app is already performing another geocoding request
                if distance > 0 {
                    performingReverseGeocoding = false
                }
            }
            
            updateLabels()
            
            
            // Checks to make sure if the app is busy performingReverseGeocoding, if it isnt then start the geocoder
            // this is done to make sure the app is only performing a single geocoding request at a time
            if !performingReverseGeocoding {
                print("*** Going to geocode")
                
                performingReverseGeocoding = true
                
                
                
                // the completionHandler bit here is only performed after the CLGeocoder finds an address or encounters an error. It's called a closure pg 599
                // we are telling the CLGeocoder object that we want to reverse geocode the location, and the code in the block following the completionHandler: should be executed as soon as the geocoding is completed
                
                // The Closure
                geocoder.reverseGeocodeLocation( newLocation,
                                                 completionHandler: { placemarks, error in
                                                    
                                                    self.lastGeocodingError = error
                                                    if error == nil, let p = placemarks, !p.isEmpty {
                                                        self.placemark = p.last!
                                                    }else {
                                                        self.placemark = nil
                                                    }
                                                    self.performingReverseGeocoding = false
                                                    self.updateLabels()
                })
            }
            // NEW #3   gives a time limit of 10 seconds from the point of the original reading
        } else if distance < 1 {
            let timeInterval = newLocation.timestamp.timeIntervalSince(location!.timestamp)
            
            if timeInterval > 10 {
                print ("*** Force done!")
                stopLocationManager()
                updateLabels()
            }
            // END OF 3
            
        }
        // location will be nil until Core Location reports back with a valid CLLocation object
        location = newLocation
        
        // clearing out the old error state, after recieving a valid a coordinate any previous error encountered is no longer applicable
        lastLocationError = nil
        
        // updating labels with coordinates
        updateLabels()
    }
    
    // MARK:- Helper Methods
    func showLocationServicesDeniedAlert(){
      
        let alert = UIAlertController(
            title: "Location Services Disabled",
            message: "Please enable location services for this app in Settings.",
            preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default,
                                     handler: nil)
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
            
    }
    
    
    func updateLabels(){
        if let location = location {
            
                                // format strings being assigned to labels, %.8f takes a decimal number and puts it in the string, the .8 means that there should always be 8 digits behind the decimal point
            latitudeLabel.text = String (format: "%.8f",
                                         location.coordinate.latitude)
            longitudeLabel.text = String(format: "%.8f",
                                         location.coordinate.longitude)
            
            tagButton.isHidden = false
            messageLabel.text = ""
            
            
            //MARK:- Displaying the address
            
            
            
            // only does the address lookup once the app has a valid location. If an address if found, the user is shown the address, otherwise a status message is shown.
            
            
            
            
            
            if let placemark = placemark {
                addressLabel.text = string(from: placemark)
            } else if performingReverseGeocoding {
                addressLabel.text = "Searching for Address..."
            } else if lastGeocodingError != nil {
                addressLabel.text = "Error Finding Address"
            } else {
                addressLabel.text = "No Address Found"
            }
            // ==============================
            
            
        }else {
            latitudeLabel.text = ""
            longitudeLabel.text = ""
            addressLabel.text = ""
            tagButton.isHidden = true
            
            // the following code determines what the messageLabel displays at the top of the screen
            
            // using if statements we can figure out the current status of the app, if the location manager gave an error the labelm will show an error message.
            let statusMessage: String
            if let error = lastLocationError as NSError? { // the first error checked for is for CLError.denied in the error domain kCLErrorDomain, meaning Core Location Errors. In that case, the user has not given this app permission to use the location services.
                if error.domain == kCLErrorDomain &&
                    error.code == CLError.denied.rawValue{
                    statusMessage = "Location Services Disabled"
                } else{ // If the error code is something else, then error getting location is displayed.
                    statusMessage = "Error Getting Location"
                }
            } else if !CLLocationManager.locationServicesEnabled(){
                statusMessage = "Location Services Disabled"
            } else if updatingLocation {
                statusMessage = "Searching..."
            }else {
                statusMessage = "Tap 'Get My Location' to Start"
            }
            messageLabel.text = statusMessage
            
            // method executed that configures different text for the GetButton depending on if the app is still searching for a location
            
            
        }
        
        
        configureGetButton()
        
    }
    
    // Method that checks whether or not the location services are eneabled, then sets updatingLocation to true if you did indeed start locaiton updates.
    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            
            // setting desired accuracy for coordinates to the nearest ten meters
            locationManager.desiredAccuracy =
                            kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            updatingLocation = true
            
            // Timer object that sends a didTimeOut message to self after 60 seconds ( didTimeOut is the name of a method )
            timer = Timer.scheduledTimer(timeInterval: 60, target: self,
                                         selector: #selector(didTimeOut), userInfo: nil,
                                         repeats: false)
            
        }
    }
    
    func stopLocationManager() {
        // this if loop checks for if the location manager is active, if active updatingLocation is true and is then made false.
        // if location manager is not active updatingLocation is false thus nothing happens
        if updatingLocation{
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
            
            
            // Cancels the timer in case the location manager is stopped before the time out fires
            if let timer = timer {
                timer.invalidate()
            }
        }
        
    }
    
    // if the app is currently updating the location then the button's title becomes Stop, otherwise it is Get My Location
    func configureGetButton() {
        if updatingLocation {
            getButton.setTitle("Stop", for: .normal)
        } else {
            getButton.setTitle("Get My Location", for: .normal)
        }
    }
    
    
    
    func string(from placemark: CLPlacemark) -> String {
        // 1
        var line1 = ""          // address will be two lines of text, create a new string variable for the first line
        
        // 2
        if let s = placemark.subThoroughfare {    // if the placemark has a subThoroughfare add it to the string, (fancy name for house number)
            line1 += s + " "
        }
        
        // 3
        if let s = placemark.thoroughfare {    // adding the thoroughfare ( street name) putting a space between it and subThoroughfare to seperate them
            line1 += s
        }
        
        
        
        // 4                                  // a new string var for the second line of text, composed of the locality ( city ), administrative area ( state or                                        province) and postal code ( zip code) with spacing between them when needed
        
        var line2 = ""
        
        if let s = placemark.locality {
            line2 += s + " "
        }
        if let s = placemark.administrativeArea {
            line2 += s + " "
        }
        if let s = placemark.postalCode {
            line2 += s
        }
        
        // 5                              Both string ( both lines) are added together with a newline character in between. The \n adds the line break to the                                // string
        return line1 + "\n" + line2
        
    }
    
    
    // @objc means can be accessed from Objective-C
    
    
    @objc func didTimeOut() {
        print("*** Time out")
        if location == nil {
            stopLocationManager()
            lastLocationError = NSError (
                    domain: "MyLocationsErrorDomain",
                    code: 1, userInfo: nil)
            updateLabels()
        }
    }
    
    
    // overrides viewWillAppear from its superclass, forcing the navigation bar to be hidden
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    // reversing what viewWillAppear does by having the navigation controller show the nav bar when the view is about to disappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    
    
    
    // using CAST to obtain the proper destination view controller and its properties
    // when the segue "TagLocation" is performed the coordinate and address are passed onto the Tag Location Screen
    
    // MARK:- Navigation
    override func prepare(for segue: UIStoryboardSegue,
                          sender: Any?) {
        if segue.identifier == "TagLocation" {
            let controller = segue.destination
                            as! LocationDetailsViewController
            controller.coordinate = location!.coordinate
            controller.placemark = placemark
        }
    }

    
    
    
}


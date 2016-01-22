//
//  ViewController.swift
//  Who's Near
//
//  Created by John Frost on 1/18/16.
//  Copyright © 2016 Pair-A-Dice. All rights reserved.
//

import UIKit
import MapKit
import Contacts
import ContactsUI

class ViewController: UIViewController, MKMapViewDelegate, CNContactPickerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!

    let locationManager = CLLocationManager()
    let regionRadius: CLLocationDistance = 2000
    
    
    var name: String = ""
    var phone: String = ""
    var formattedAddress: String = ""
    var locStr:String = ""
    var contacts = [CNContact]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        //mapView.mapType = MKMapType.Hybrid
        
        findContacts()
    
        for contact in contacts {
        
            let address = contact.postalAddresses
            let formatter = CNPostalAddressFormatter()
            for address1 in address {
                if CNLabeledValue.localizedStringForLabel(address1.label) == "home"{
                    name = CNContactFormatter.stringFromContact(contact , style: .FullName)!
                    let addr = address1.value as! CNPostalAddress
                    locStr = ("\(addr.street) \(addr.city) \(addr.state) \(addr.postalCode) ")
                    formattedAddress = formatter.stringFromPostalAddress(addr)
                    getPlacemarkFromAddress(locStr)
                    
                    print(name)
                    print(locStr)
                    print(formattedAddress)
        
                    
                } else {
                    //locStr = ""
                    //formattedAddress = ""
                    //name = ""
                }
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        
        locationAuthStatus()
    }
    
    func locationAuthStatus() {
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse{
            mapView.showsUserLocation = true
        }else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 10, regionRadius * 10)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        if let loc = userLocation.location {
            centerMapOnLocation(loc)
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKindOfClass(ContactAnnotation) {
            let annoView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "Default")
            annoView.pinTintColor = UIColor.blueColor()
            annoView.canShowCallout = true
            annoView.animatesDrop = true
            let btn = UIButton(type: .DetailDisclosure)
            annoView.rightCalloutAccessoryView = btn
            return annoView
            
        }else if annotation.isKindOfClass(MKUserLocation) {
            return nil
        }
        return nil
    }
    
    func createAnnotationForLocation(location: CLLocation) {
        
        let anno = ContactAnnotation(coordinate: location.coordinate, title: name, subtitle: self.formattedAddress)
 
        print(anno.coordinate)
        print(anno.title)
        print(anno.subtitle)
        mapView.addAnnotation(anno)
    }
    
    func getPlacemarkFromAddress(address: String) {
       
        CLGeocoder().geocodeAddressString(address) { (placemarks: [CLPlacemark]?, error: NSError?) -> Void in
            if let marks = placemarks where marks.count > 0 {
                if let loc = marks[0].location {
                    self.createAnnotationForLocation(loc)
                    
                }
            }else {
                print("Returned an Error")
            }
        }
        
    }
    
    func findContacts() -> [CNContact] {
        let store = CNContactStore()
        
        let keysToFetch = [CNContactFormatter.descriptorForRequiredKeysForStyle(.FullName), CNContactPhoneNumbersKey, CNContactPostalAddressesKey]
        let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch)
        
        
        do {
            try store.enumerateContactsWithFetchRequest(fetchRequest, usingBlock: { (let contact, let stop) -> Void in
                self.contacts.append(contact)
            })
        }
        catch let error as NSError {
            print(error.localizedDescription)
        }
        return contacts
    }
}


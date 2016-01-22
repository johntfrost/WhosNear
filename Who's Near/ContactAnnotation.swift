//
//  ContactAnnotation.swift
//  Who's Near
//
//  Created by John Frost on 1/18/16.
//  Copyright © 2016 Pair-A-Dice. All rights reserved.
//

import Foundation
import MapKit

class ContactAnnotation: NSObject, MKAnnotation{
    
    var coordinate = CLLocationCoordinate2D()
    var title: String?
    var subtitle: String?
    
    
    init (coordinate: CLLocationCoordinate2D, title: String, subtitle: String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
    
    
}
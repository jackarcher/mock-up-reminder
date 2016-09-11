//
//  myPinAnnotation.swift
//  fit5140assign1
//
//  Created by Jack N. Archer on 11/09/2016.
//  Copyright © 2016 Jack N. Archer. All rights reserved.
//

import UIKit
import MapKit

class myPinAnnotation: MKPointAnnotation {
    var c:Category!
    
    init(c:Category!) {
        super.init()
        self.c = c
    }
}

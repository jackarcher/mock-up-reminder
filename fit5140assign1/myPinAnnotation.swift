//
//  myPinAnnotation.swift
//  fit5140assign1
//
//  Created by Jack N. Archer on 11/09/2016.
//  Copyright © 2016 Jack N. Archer. All rights reserved.
//

import UIKit
import MapKit

// just add a var to mkpointannotation, to also store the category for this annotation
class myPinAnnotation: MKPointAnnotation {
    // the category for this annotation
    var c:Category!
    // add init
    init(c:Category!) {
        super.init()
        self.c = c
    }
}

//
//  PlaceHolderViewController.swift
//  fit5140assign1
//
//  Created by Jack N. Archer on 9/09/2016.
//  Copyright © 2016 Jack N. Archer. All rights reserved.
//

import UIKit

// just a place holder to provide some indications for the user in detail view
class PlaceHolderViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // potait back button
        self.tabBarController?.tabBar.hidden = true
        self.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

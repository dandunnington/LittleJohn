//
//  NoNavBarTabController.swift
//  LittleJohn
//
//  Created by Dan Dunnington on 23/02/2020.
//  Copyright © 2020 Dan Dunnington. All rights reserved.
//

import Foundation
import UIKit

class NoNavBarTabController: UITabBarController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
}

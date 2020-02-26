//
//  MockTabBarController.swift
//  LittleJohn
//
//  Created by Dan Dunnington on 24/02/2020.
//  Copyright © 2020 Dan Dunnington. All rights reserved.
//

import Foundation
@testable import LittleJohn

class MockTabBarController: ViewControllerMock, UITabBarControllerType {
    
    var lastSetViewControllers: [UIViewControllerType]?
    
    func setViewControllers(_ viewControllers: [UIViewControllerType]) {
        lastSetViewControllers = viewControllers
    }
    
}

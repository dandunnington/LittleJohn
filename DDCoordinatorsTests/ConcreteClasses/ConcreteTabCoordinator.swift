//
//  ConcreteTabCoordinator.swift
//  LittleJohn
//
//  Created by Dan Dunnington on 24/02/2020.
//  Copyright © 2020 Dan Dunnington. All rights reserved.
//

import Foundation
@testable import LittleJohn

class ConcreteTabCoordinator: TabCoordinator {
    
    // MARK: - Injectable Functions
    var createChildrenClosure: (() -> [TabCoordinator.Tab])?
    
    var createTabControllerClosure: (() -> UITabBarControllerType)?
    
    // MARK: - Overrides
    override func createChildren() -> [TabCoordinator.Tab] {
        return createChildrenClosure!()
    }
    
    override func createTabBarController() -> UITabBarControllerType {
        return createTabControllerClosure!()
    }
    
}

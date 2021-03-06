//
//  MockCoordinatorType.swift
//  LittleJohnTests
//
//  Created by Dan Dunnington on 16/02/2020.
//  Copyright © 2020 Dan Dunnington. All rights reserved.
//

import Foundation
@testable import LittleJohn

class MockCoordinatorType: CoordinatorType {
    
    var lastStartCall: Start?
    func start(animated: Bool, completion: (() -> Void)?) {
        lastStartCall = Start(animated: animated, completion: completion)
    }
    
    var deallocateStrongNavCalled = false
    func deallocateStrongNavController() {
        deallocateStrongNavCalled = true
    }
    
    var parent: CoordinatorType?
    
    var rootViewController: UIViewControllerType?
    
    var _strongNavigationController: UINavigationControllerType?
    
    struct Start {
        let animated: Bool
        let completion: (() -> Void)?
    }
    
    
}

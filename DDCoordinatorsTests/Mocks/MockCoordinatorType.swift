//
//  MockCoordinatorType.swift
//  DDCoordinatorsTests
//
//  Created by Dan Dunnington on 16/02/2020.
//  Copyright © 2020 Dan Dunnington. All rights reserved.
//

import Foundation
@testable import DDCoordinators

class MockCoordinatorType: CoordinatorType {
    
    var lastStartCall: Start?
    func start(animated: Bool, completion: (() -> Void)?) {
        lastStartCall = Start(animated: animated, completion: completion)
    }
    
    var parent: CoordinatorType?
    
    var rootViewController: UIViewControllerType?
    
    var _strongNavigationController: UINavigationControllerType?
    
    struct Start {
        let animated: Bool
        let completion: (() -> Void)?
    }
    
    
}

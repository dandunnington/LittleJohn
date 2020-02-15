//
//  DelegatingCoordinator.swift
//  DDCoordinators
//
//  Created by Dan Dunnington on 29/01/2020.
//  Copyright © 2020 Dan Dunnington. All rights reserved.
//

import Foundation
import UIKit

open class DelegatingCoordinator<DataOutput>: Coordinator<DataOutput> {
    
    open func makeDelegatingCoordinator() -> CoordinatorType {
        fatalError("Must be implemented")
    }
    
    private weak var delegatingCoordinator: CoordinatorType?
    
    override func displayUI(animated: Bool) {
        super.displayUI(animated: animated)
        
        let coordinator = makeDelegatingCoordinator()
        coordinator.start(animated: false, completion: nil)
        delegatingCoordinator = coordinator
    }
    
    override public var rootViewController: UIViewControllerType? {
        return delegatingCoordinator?.rootViewController
    }
    
}

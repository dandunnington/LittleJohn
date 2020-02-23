//
//  ViewControllerCoordinator.swift
//  LittleJohn
//
//  Created by Dan Dunnington on 29/01/2020.
//  Copyright © 2020 Dan Dunnington. All rights reserved.
//

import Foundation
import UIKit

/**
 A `Coordinator` subclass that displays a specified view controller when started
 */
open class ViewControllerCoordinator<DataOutput>: Coordinator<DataOutput> {
    
    open func makeRootViewController() -> UIViewControllerType {
        fatalError("Root view controller must be overriden")
    }
    
    override func displayUI(animated: Bool) {
        
        let viewController = makeRootViewController()
        
        guard let strongNavController = _strongNavigationController else {
            return
        }
        
        switch presentingStrategy {
        case .pushNavigationController, .pushFromCoordinator, .tab:
            strongNavController.pushViewControllerType(viewController, animated: animated)
        case .present(modalConfig: let config):
            strongNavController.pushViewControllerType(viewController, animated: false)
            config.presentingController.present(config.configureForPresentation(controller: strongNavController), animated: animated)
        case .none: break
        }

        self.initialViewController = viewController
        
    }
    
    override public final var rootViewController: UIViewControllerType? {
        return initialViewController
    }
    
    /**
     Defines how the coordinator's `initialViewController` is displayed
     */
    
    private weak var initialViewController: UIViewControllerType?
    
    
}

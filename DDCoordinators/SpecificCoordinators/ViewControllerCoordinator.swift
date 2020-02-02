//
//  ViewControllerCoordinator.swift
//  DDCoordinators
//
//  Created by Dan Dunnington on 29/01/2020.
//  Copyright © 2020 Dan Dunnington. All rights reserved.
//

import Foundation
import UIKit

open class ViewControllerCoordinator<DataOutput>: Coordinator<DataOutput> {
    
    open func makeRootViewController() -> UIViewController {
        fatalError("Root view controller must be overriden")
    }
    
    override func displayUI(animated: Bool) {
        
        let viewController = makeRootViewController()
        
        guard let strongNavController = _strongNavigationController else {
            return
        }
        
        switch presentingStrategy {
        case .pushNavigationController, .pushFromCoordinator:
            strongNavController.pushViewController(viewController, animated: animated)
        case .present(modalConfig: let config):
            strongNavController.pushViewController(viewController, animated: false)
            config.presentingController.present(config.configureForPresentation(controller: strongNavController), animated: animated)
        case .none: break
        }

        self.initialViewController = viewController
        
    }
    
    override public final var rootViewController: UIViewController? {
        return initialViewController
    }
    
    /**
     Defines how the coordinator's `initialViewController` is displayed
     */
    
    private weak var initialViewController: UIViewController?
    
    
}

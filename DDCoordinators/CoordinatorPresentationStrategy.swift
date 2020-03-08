//
//  CoordinatorPresentationStrategy.swift
//  CyclingTracker
//
//  Created by Dan Dunnington on 27/12/2019.
//  Copyright © 2019 Dan Dunnington. All rights reserved.
//

import Foundation
import UIKit

/**
 Represents how a coordinator should present it's initial view controller
 */
public enum CoordinatorPresentingStrategy {
    
    /// The coordinators navigation controller is presented on top of its parent's view controller
    case present(modalConfig: ModalConfiguration)
    
    case pushNavigationController(_: UINavigationControllerType)
    
    case pushFromCoordinator(_: CoordinatorType)
    
    case presentFromCoordinator(_: CoordinatorType)
    
    case tab
    
    internal var endingStrategy: CoordinatorEndingStrategy {
        switch self {
        case .present, .presentFromCoordinator:
            return .dismiss
        case .pushNavigationController, .pushFromCoordinator:
            return .pop
        case .tab:
            return .none
        }
    }
    
    /**
     The configuration struct for modally presented coordinators
     */
    public struct ModalConfiguration {
        
        /// The `UIViewController` to present the coordinator from
        let presentingController: UIViewControllerType
        
        /// The style to use when presenting the coordinator
        let presentationStyle: UIModalPresentationStyle
        
        /// The transition style to use when presenting the coordinator
        let transitionStyle: UIModalTransitionStyle
        
        /**
         Configures the given view controller using this objects properties
         */
        func configureForPresentation(controller: UIViewControllerType) -> UIViewControllerType {
            controller.definesPresentationContext = true
            controller.modalTransitionStyle = transitionStyle
            controller.modalPresentationStyle = presentationStyle
            return controller
        }
    }
}

internal enum CoordinatorEndingStrategy {
    case dismiss
    case pop
    case none
}

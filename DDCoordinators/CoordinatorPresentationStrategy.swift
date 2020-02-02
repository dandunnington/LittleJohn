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
    
    case pushNavigationController(_: UINavigationController)
    
    case pushFromCoordinator(_: CoordinatorType)
    
    init(presentedByParent parent: CoordinatorType, transitionStyle: UIModalTransitionStyle, presentationStyle: UIModalPresentationStyle) {
        
        guard let presentingController = parent.navigationController else {
            fatalError("Tried to present view controller on top of coordinators non-existent navigation controller")
        }
        
        self = .present(modalConfig: CoordinatorPresentingStrategy.ModalConfiguration(
            presentingController: presentingController,
            presentationStyle: presentationStyle, transitionStyle: transitionStyle)
        )
    }
    
    internal var endingStrategy: CoordinatorEndingStrategy {
        switch self {
        case .present:
            return .dismiss
        case .pushNavigationController, .pushFromCoordinator:
            return .pop
        }
    }
    
    /**
     The configuration struct for modally presented coordinators
     */
    public struct ModalConfiguration {
        
        /// The `UIViewController` to present the coordinator from
        let presentingController: UIViewController
        
        /// The style to use when presenting the coordinator
        let presentationStyle: UIModalPresentationStyle
        
        /// The transition style to use when presenting the coordinator
        let transitionStyle: UIModalTransitionStyle
        
        /**
         Configures the given view controller using this objects properties
         */
        func configureForPresentation(controller: UIViewController) -> UIViewController {
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
}

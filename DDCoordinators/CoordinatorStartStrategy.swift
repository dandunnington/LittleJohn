//
//  CoordinatorStartStrategy.swift
//  CyclingTracker
//
//  Created by Dan Dunnington on 28/12/2019.
//  Copyright © 2019 Dan Dunnington. All rights reserved.
//

import Foundation
import UIKit

/**
 Represents the strategy employed by the coordinator when it starts
 */
public enum CoordinatorStartStrategy {
    
    /// Starts the coordinator by displaying the passed view controller using the `presentingStrategy`
    case viewController(_: UIViewController)
    
    /// Starts the coordinator by starting a child coordinator
    case childCoordinator(_: CoordinatorType)
}

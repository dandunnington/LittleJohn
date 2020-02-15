//
//  ViewControllerMock.swift
//  DDCoordinatorsTests
//
//  Created by Dan Dunnington on 15/02/2020.
//  Copyright © 2020 Dan Dunnington. All rights reserved.
//

import Foundation
@testable import DDCoordinators
import UIKit

class ViewControllerMock: UIViewControllerType {
    
    // MARK: - Recorder variables
    var present: Present?
    
    var dismiss: Dismiss?
    
    // MARK: - Conformance
    var definesPresentationContext: Bool = false
    
    var modalTransitionStyle: UIModalTransitionStyle = .coverVertical
    
    var modalPresentationStyle: UIModalPresentationStyle = .automatic
    
    func present(_ viewControllerToPresent: UIViewControllerType, animated: Bool, completion: (() -> Void)?) {
        present = Present(viewControllerToPresent: viewControllerToPresent, animated: animated, completion: completion)
    }
    
    public weak var navigationControllerType: UINavigationControllerType?
    
    func dismiss(animated: Bool, completion: (() -> Void)?) {
        dismiss = Dismiss(animated: animated, completion: completion)
    }
    
    struct Present {
        let viewControllerToPresent: UIViewControllerType
        let animated: Bool
        let completion: (() -> Void)?
    }
    
    struct Dismiss {
        let animated: Bool
        let completion: (() -> Void)?
    }
}

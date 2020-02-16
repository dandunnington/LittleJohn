//
//  BaseIntCoordinatorConceteClass.swift
//  LittleJohnTests
//
//  Created by Dan Dunnington on 02/02/2020.
//  Copyright © 2020 Dan Dunnington. All rights reserved.
//

import Foundation
@testable import LittleJohn

class ViewControllerIntCoordinator: ViewControllerCoordinator<Int> {
    
    // MARK: - Recording Variables
    var didStartLastAnimated: Bool?
    
    var displayUICalledValue: Bool?
    
    var willCancelAnimated: Bool?
    
    var willCompleteCall: (data: Int, animated: Bool)?
    
    // MARK: - Injection Variables
    var makeRootViewControllerClosure: (() -> UIViewControllerType)?
    
    // MARK: - Override Hooks For Testing
    override func didStart(animated: Bool) {
        didStartLastAnimated = animated
    }
    
    override func willCancel(animated: Bool) {
        willCancelAnimated = animated
    }
    
    override func willComplete(data: Int, animated: Bool) {
        willCompleteCall = (data: data, animated: animated)
    }
    
    // MARK: - Conformance
    override func makeRootViewController() -> UIViewControllerType {
        return makeRootViewControllerClosure!()
    }
    
}

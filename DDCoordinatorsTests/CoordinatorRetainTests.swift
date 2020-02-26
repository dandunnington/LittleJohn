//
//  CoordinatorRetainTests.swift
//  LittleJohnTests
//
//  Created by Dan Dunnington on 26/02/2020.
//  Copyright © 2020 Dan Dunnington. All rights reserved.
//

import Foundation
import XCTest
@testable import LittleJohn

class CoordinatorRetainTests: XCTestCase {
    
    weak var weakCoordinatorReference: ViewControllerIntCoordinator?
    
    
    func testCoordinatorDeallocatedWhenViewControllerDeallocated() {
        
        // given
        
        var sut: ViewControllerIntCoordinator? = ViewControllerIntCoordinator(
            presentingStrategy: .pushNavigationController(NavigationControllerMock())
        )
        
        var vc: ViewControllerMock? = ViewControllerMock()
        sut?.makeRootViewControllerClosure = { return vc! }
        weakCoordinatorReference = sut
        
        // when
        sut?.start(animated: true)
        sut = nil // by this point the coordinator should be retained by the view controller
        
        // then
        XCTAssertNotNil(weakCoordinatorReference)
        
        // when
        vc = nil // simulate view controller being popped off stack
        
        // then
        XCTAssertNil(weakCoordinatorReference)
    }
    
}

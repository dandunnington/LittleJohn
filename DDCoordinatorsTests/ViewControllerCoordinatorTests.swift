//
//  DDCoordinatorsTests.swift
//  DDCoordinatorsTests
//
//  Created by Dan Dunnington on 04/01/2020.
//  Copyright © 2020 Dan Dunnington. All rights reserved.
//

import XCTest
import UIKit
@testable import DDCoordinators

class ViewControllerCoordinatorTests: XCTestCase {

    weak var coordinator: ViewControllerIntCoordinator!
    
    private var viewController: ViewControllerMock?
    
    private func completedFunc(outputVal: Int) {
        
    }
    
    private func cancelledFunc() {
        
    }
    
    override func setUp() {
        
        coordinator = ViewControllerIntCoordinator(
            presentingStrategy: .pushNavigationController(UINavigationController()),
            completed: completedFunc(outputVal:),
            cancelled: cancelledFunc
        )
        
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

}

extension BaseCoordinatorTests {
    
    func testRootController() {
        
    }
}

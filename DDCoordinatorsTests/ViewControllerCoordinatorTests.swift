//
//  LittleJohnTests.swift
//  LittleJohnTests
//
//  Created by Dan Dunnington on 04/01/2020.
//  Copyright © 2020 Dan Dunnington. All rights reserved.
//

import XCTest
import UIKit
@testable import LittleJohn

class ViewControllerCoordinatorTests: XCTestCase {
        
    weak var weakCoordinator: ViewControllerIntCoordinator?
    
    
    // MARK: - Capture Methods and Recording
    var completedVal: Int?
    var cancelledCalled = false
    private func completedFunc(outputVal: Int) {
        completedVal = outputVal
    }
    
    private func cancelledFunc() {
        cancelledCalled = true
    }
    
    override func setUp() {
        
        completedVal = nil
        cancelledCalled = false
        
    }

    override func tearDown() {
        completedVal = nil
        cancelledCalled = false
    }

}

// MARK: - Start Tests
extension ViewControllerCoordinatorTests {
    
    func testRootViewControllerPushedOnStart() {
        
        let navigationController = NavigationControllerMock()
        
        // given
        let coordinator = ViewControllerIntCoordinator(
            presentingStrategy: .pushNavigationController(navigationController),
            completed: completedFunc(outputVal:),
            cancelled: cancelledFunc
        )
        
        let viewController = ViewControllerMock()
        
        coordinator.makeRootViewControllerClosure = {
            return viewController
        }
        
        // when
        coordinator.start(animated: true, completion: nil)
        
        // then
        XCTAssertEqual(navigationController.viewControllers.count, 1)
        XCTAssert(navigationController.viewControllers.first === viewController)
    }
    
    func testRootControllerPresentedOnStart() {
        
        let coordinatorViewController = ViewControllerMock()
        let presentingViewController = ViewControllerMock()
        let createdNavController = NavigationControllerMock()
        
        // given
        let coordinator = ViewControllerIntCoordinator(
            presentingStrategy: .present(modalConfig: .init(presentingController: presentingViewController, presentationStyle: .fullScreen, transitionStyle: .crossDissolve)),
            completed: completedFunc(outputVal:),
            cancelled: cancelledFunc
        )
        
        coordinator.makeRootViewControllerClosure = { coordinatorViewController }
        coordinator.createNavController = { createdNavController }
        
        // when
        coordinator.start(animated: true, completion: nil)
        
        // then
        
        // nav controller should have been presented on presenting view controller
        XCTAssert(presentingViewController.present?.viewControllerToPresent === createdNavController)
        XCTAssertTrue(presentingViewController.present?.animated ?? false)
        XCTAssertTrue(createdNavController.definesPresentationContext)
        XCTAssertEqual(createdNavController.modalPresentationStyle, .fullScreen)
        XCTAssertEqual(createdNavController.modalTransitionStyle, .crossDissolve)
        
        // nav controller chouls contain root view controll
        XCTAssertEqual(createdNavController.viewControllers.count, 1)
        XCTAssert(createdNavController.viewControllers.first === coordinatorViewController)
    }
    
    func testPushFromCoordinatorNavControllerAlreadyInHierachy() {
        
        // given
        let parentCoordinator = MockCoordinatorType()
        
        // hold reference to nav controller here to simulate it beging retained by UIKit
        let navController = NavigationControllerMock()
        let parentRootController = ViewControllerMock()
        parentRootController.navigationControllerType = navController
        parentCoordinator.rootViewController = parentRootController
        navController.viewControllers = [parentRootController]
        
        let rootControllerForNew = ViewControllerMock()
        
        let coordinator = ViewControllerIntCoordinator(
            presentingStrategy: .pushFromCoordinator(parentCoordinator),
            completed: completedFunc(outputVal:),
            cancelled: cancelledFunc)
        
        coordinator.makeRootViewControllerClosure = { rootControllerForNew }
        
        // when
        coordinator.start(animated: true)
        
        // then
        XCTAssertEqual(navController.viewControllers.count, 2)
        XCTAssert(navController.viewControllers[0] === parentRootController)
        XCTAssert(navController.viewControllers[1] === rootControllerForNew)
        
        // see Navigation Controller mock for details about a strange issue with then navigation controller property on `ViewControllerMock`
        // otherwise we would check the nav controller property of the mock view controller
        // the test below suffices just as well though 😀
        XCTAssert(navController.lastPushViewControllerType?.animated ?? false)
        XCTAssert(navController.lastPushViewControllerType?.viewController === rootControllerForNew)
    }
    
    func testRootViewController() {
        
        // given
        let navigationController = NavigationControllerMock()
        let viewController = ViewControllerMock()
        
        let coordinator = ViewControllerIntCoordinator(presentingStrategy: .pushNavigationController(navigationController))
        
        coordinator.makeRootViewControllerClosure = { viewController }
        
        // when
        coordinator.start(animated: true)
        
        // then
        XCTAssert(coordinator.rootViewController === viewController)
    }
}

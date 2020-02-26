//
//  TabCoordinatorTests.swift
//  LittleJohn
//
//  Created by Dan Dunnington on 24/02/2020.
//  Copyright © 2020 Dan Dunnington. All rights reserved.
//

import Foundation
import XCTest
@testable import LittleJohn

class TabCoordinatorTests: XCTestCase {
        
    var sut: ConcreteTabCoordinator!
    
    var tab1: MockCoordinatorType!
    var tab2: MockCoordinatorType!
    var tab3: MockCoordinatorType!
    
    var vc1: ViewControllerMock!
    var vc2: ViewControllerMock!
    var vc3: ViewControllerMock!
    
    var nav1: NavigationControllerMock!
    var nav2: NavigationControllerMock!
    var nav3: NavigationControllerMock!
    
    var barItem1: UITabBarItem!
    var barItem2: UITabBarItem!
    var barItem3: UITabBarItem!
    
    var tabBarController: MockTabBarController!
    
    var pushingNav = NavigationControllerMock()
    
    override func setUp() {
        super.setUp()
        
        vc1 = ViewControllerMock()
        vc2 = ViewControllerMock()
        vc3 = ViewControllerMock()
        
        nav1 = NavigationControllerMock()
        nav2 = NavigationControllerMock()
        nav3 = NavigationControllerMock()
        
        tab1 = MockCoordinatorType()
        tab1._strongNavigationController = nav1
        tab1.rootViewController = vc1
        
        tab2 = MockCoordinatorType()
        tab2._strongNavigationController = nav2
        tab2.rootViewController = vc2
        
        tab3 = MockCoordinatorType()
        tab3._strongNavigationController = nav3
        tab3.rootViewController = vc3
        
        barItem1 = UITabBarItem(title: "Tab1", image: nil, tag: 0)
        barItem2 = UITabBarItem(title: "Tab2", image: nil, tag: 1)
        barItem3 = UITabBarItem(title: "Tab3", image: nil, tag: 2)
        
        tabBarController = MockTabBarController()
        
        sut = ConcreteTabCoordinator(presentingStrategy: .pushNavigationController(pushingNav))
        
        sut.createChildrenClosure = { [unowned self] in
            return [
                TabCoordinator.Tab(coordinator: self.tab1, tabBarItem: self.barItem1),
                TabCoordinator.Tab(coordinator: self.tab2, tabBarItem: self.barItem2),
                TabCoordinator.Tab(coordinator: self.tab3, tabBarItem: self.barItem3)
            ]
        }
        
        sut.createTabControllerClosure = { [unowned self] in
            return self.tabBarController
        }
        
    }
    
    override func tearDown() {
        super.tearDown()
        sut = nil
        vc1 = nil
        vc2 = nil
        vc3 = nil
        tab1 = nil
        tab2 = nil
        tab3 = nil
        nav1 = nil
        nav2 = nil
        nav3 = nil
        barItem1 = nil
        barItem2 = nil
        barItem3 = nil
        tabBarController = nil
    }
    
}

// MARK: - Tests
extension TabCoordinatorTests {
    
    func testTabCoordinatorsStarted() {
        
        // when
        sut.start(animated: true)
        
        // then
        XCTAssertNotNil(tab1.lastStartCall)
        XCTAssertNotNil(tab2.lastStartCall)
        XCTAssertNotNil(tab3.lastStartCall)
        
    }
    
    func testTabViewControllersAreNavControllers() {
        
        // when
        sut.start(animated: true)
        
        // then
        guard let viewControllers = tabBarController.lastSetViewControllers else {
            return XCTFail("tab controllers should have had it's view controllers set")
        }
        
        XCTAssertEqual(viewControllers.count, 3)
        XCTAssert(viewControllers[0] === nav1)
        XCTAssert(viewControllers[1] === nav2)
        XCTAssert(viewControllers[2] === nav3)
        
    }
    
    func testTabBarItems() {
        
        // when
        sut.start(animated: true)
        
        // then
        guard let viewControllers = tabBarController.lastSetViewControllers else {
            return XCTFail("tab controllers should have had it's view controllers set")
        }
        
        XCTAssertEqual(viewControllers.count, 3)
        
        XCTAssert(viewControllers[0].tabBarItem === barItem1)
        XCTAssert(viewControllers[1].tabBarItem === barItem2)
        XCTAssert(viewControllers[2].tabBarItem === barItem3)
        
    }
    
    func testStrongNavigationControllerDeallocated() {
        // when
        sut.start(animated: true)
        
        guard let viewControllers = tabBarController.lastSetViewControllers else {
            return XCTFail("tab controllers should have had it's view controllers set")
        }
        
        XCTAssertEqual(viewControllers.count, 3)
        
        XCTAssertTrue(tab1.deallocateStrongNavCalled)
        XCTAssertTrue(tab2.deallocateStrongNavCalled)
        XCTAssertTrue(tab3.deallocateStrongNavCalled)
        
    }
    
    func testTabControllerPush() {
        // when
        sut.start(animated: true)
        
        // then
        XCTAssertEqual(pushingNav.viewControllers.count, 1)
        XCTAssert(pushingNav.viewControllers.first === tabBarController)
    }
    
}

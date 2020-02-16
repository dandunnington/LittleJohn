//
//  CoordinatorPresentationStrategyTests.swift
//  DDCoordinatorsTests
//
//  Created by Dan Dunnington on 16/02/2020.
//  Copyright © 2020 Dan Dunnington. All rights reserved.
//

import Foundation
import XCTest
@testable import DDCoordinators

class CoordinatorPresentationStrategyTests: XCTestCase {
    
    func testConvenienceInit() {
        
        let parent = MockCoordinatorType()
        let rootViewController = ViewControllerMock()
        let navigationController = NavigationControllerMock()
        rootViewController.navigationControllerType = navigationController
        parent.rootViewController = rootViewController
        
        // when
        let sut = CoordinatorPresentingStrategy(presentedByParent: parent, transitionStyle: .crossDissolve, presentationStyle: .fullScreen)
        
        // then
        guard case .present(modalConfig: let config) = sut else {
            return XCTFail("Strategy should be of type present")
        }
        XCTAssertEqual(config.transitionStyle, .crossDissolve)
        XCTAssertEqual(config.presentationStyle, .fullScreen)
        XCTAssert(config.presentingController === navigationController)
        
    }
    
    func testEndStrategyPresent() {
        
        // given
        let sut = CoordinatorPresentingStrategy.present(modalConfig: .init(presentingController: ViewControllerMock(), presentationStyle: .overCurrentContext, transitionStyle: .flipHorizontal))
        
        // when
        let endStrat = sut.endingStrategy
        
        // then
        XCTAssertEqual(endStrat, .dismiss)
        
    }
    
    func testEndStrategyPushExplictNav() {
        
        // given
        let sut = CoordinatorPresentingStrategy.pushNavigationController(NavigationControllerMock())
        
        // when
        let endStrat = sut.endingStrategy
        
        // then
        XCTAssertEqual(endStrat, .pop)
        
    }
    
    func testEndStrategyPushFromCoordinator() {
        
        // given
        let sut = CoordinatorPresentingStrategy.pushFromCoordinator(MockCoordinatorType())
        
        // when
        let endStrat = sut.endingStrategy
        
        // then
        XCTAssertEqual(endStrat, .pop)
        
    }
    
    func testControllerConfiguring() {
        
        // given
        let presentingController = ViewControllerMock()
        let presentedController = ViewControllerMock()
        
        let config = CoordinatorPresentingStrategy.ModalConfiguration(
            presentingController: presentingController,
            presentationStyle: .currentContext,
            transitionStyle: .coverVertical
        )
                
        // when
        let outputController = config.configureForPresentation(controller: presentedController)
        
        // then
        XCTAssertEqual(presentedController.modalPresentationStyle, .currentContext)
        XCTAssertEqual(presentedController.modalTransitionStyle, .coverVertical)
        XCTAssert(presentedController.definesPresentationContext)
        XCTAssert(presentedController === outputController)
    }
    
}

//
//  AppCoordinatorType.swift
//  LittleJohn
//
//  Created by Dan Dunnington on 07/03/2020.
//  Copyright © 2020 Dan Dunnington. All rights reserved.
//

import Foundation
import UIKit

public protocol AppCoordinatorType: CoordinatorType { }

public extension AppCoordinatorType {
    func performNotificationRoute(userInfo: [AnyHashable: Any]) {
        
        guard let pathJSON = userInfo["coordinatorPath"] as? [String: Any] else { return }
        
        do {
            let path = try NotificationPath(json: pathJSON, initialCoordinator: self)
            try self.action(notificationPath: path)
        } catch {
            print(error.localizedDescription)
        }
        
    }
}

// MARK: - Coordinator Functions
public extension AppCoordinatorType {
    
    func action(notificationPath: NotificationPath, usingRegister register: NotficationCoordinatorRegister = .shared) throws {
        
        // pop to the root view controller of the navigation stack and dismiss presented controller
        self.navigationController?.popToRootViewControllerType(animated: false)
        self.navigationController?.presentedViewControllerType?.dismiss(animated: false)
        
        // store all coordinators in array before starting to verify that the sequence is parsable
        var currentCoordinator = notificationPath.initialCoordinator
        var coordinators: [CoordinatorType] = []
        for item in notificationPath.items {
            
            var presentingStrategy: CoordinatorPresentingStrategy
            switch item.presentationStyle {
            case .push:
                presentingStrategy = .pushFromCoordinator(currentCoordinator)
            case .present(let style):
                presentingStrategy = .presentFromCoordinator(CoordinatorModalConfiguration(
                    presentingCoordinator: currentCoordinator,
                    presentationStyle: style,
                    transitionStyle: .coverVertical) // transition style not actually used
                )
            }
            
            guard let coordinatorType = register.coordinatorFor(identifer: item.coordinator) else {
                throw NotificationParseError.idNotRegistered
            }
            guard let coordinator = coordinatorType.init(data: item.inputData, presentationStrategy: presentingStrategy) else {
                throw NotificationParseError.invalidInputData
            }
            coordinators.append(coordinator)
            currentCoordinator = coordinator
        }
        
        // start all coordiantors one by one
        currentCoordinator = notificationPath.initialCoordinator
        for coordinator in coordinators {
            currentCoordinator.startChildType(animated: true, coordinator)
            currentCoordinator = coordinator
        }
        
    }
    
}

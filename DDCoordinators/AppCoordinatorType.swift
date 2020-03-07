//
//  AppCoordinatorType.swift
//  LittleJohn
//
//  Created by Dan Dunnington on 07/03/2020.
//  Copyright © 2020 Dan Dunnington. All rights reserved.
//

import Foundation
import UIKit

protocol AppCoordinatorType: CoordinatorType { }

extension AppCoordinatorType {
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
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
extension AppCoordinatorType {
    
    func action(notificationPath: NotificationPath, usingRegister register: NotficationCoordinatorRegister = .shared) throws {
        
        // store all coordinators in array before starting to verify that the sequence is parsable
        var currentCoordinator = notificationPath.initialCoordinator
        var coordinators: [CoordinatorType] = []
        for item in notificationPath.items {
            
            var presentingStrategy: CoordinatorPresentingStrategy
            switch item.presentationStyle {
            case .push:
                presentingStrategy = .pushFromCoordinator(currentCoordinator)
            case .present:
                presentingStrategy = .init(presentedByParent: currentCoordinator,
                                           transitionStyle: .flipHorizontal,
                                           presentationStyle: .popover)
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

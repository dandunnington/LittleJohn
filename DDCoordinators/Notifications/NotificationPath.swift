//
//  NotificationPath.swift
//  LittleJohn
//
//  Created by Dan Dunnington on 02/03/2020.
//  Copyright © 2020 Dan Dunnington. All rights reserved.
//

import Foundation

public struct NotificationPath {
    
    let identifier: String?
    
    let items: [Item]
    
    let initialCoordinator: CoordinatorType
    
    init(json: [String: Any], initialCoordinator: CoordinatorType) throws {
        self.initialCoordinator = initialCoordinator
        
        // json parse
        identifier = json["id"] as? String
        guard let itemJsons = json["items"] as? [[String: Any]] else {
            throw NotificationParseError.invalidNotificationPath
        }
        self.items = try itemJsons.map { try Item(fromJSON: $0) }
    }
    
    // MARK: - Supporting Structures
    public struct Item {
        let coordinator: CoordinatorIdentifier
        let presentationStyle: PresentationStyle
        let inputData: [String: Any]
        
        init(fromJSON json: [String: Any]) throws {
            guard let id = json["id"] as? String else {
                throw NotificationParseError.itemJSONInvalid
            }
            guard let presentStr = json["present"] as? String, let present = PresentationStyle(rawValue: presentStr) else {
                throw NotificationParseError.itemJSONInvalid
            }
            guard let inputData = json["data"] as? [String: Any] else {
                throw NotificationParseError.itemJSONInvalid
            }
            self.coordinator = CoordinatorIdentifier(name: id)
            self.presentationStyle = present
            self.inputData = inputData
        }
        
    }
    
    public enum PresentationStyle: String, Decodable {
        case push
        case present
    }
}

public enum NotificationParseError: String, Error {
    case idNotRegistered
    case invalidInputData
    case itemJSONInvalid
    case invalidNotificationPath
}

public struct NotficationCoordinatorRegister {
    
    // MARK: - Public Interface
    public mutating func register(_ coordinator: NotificationEnabledCoordinator.Type, forIdentifier id: CoordinatorIdentifier) {
        items[id] = coordinator
    }
    
    public static var shared = NotficationCoordinatorRegister()
    
    internal func coordinatorFor(identifer: CoordinatorIdentifier) -> NotificationEnabledCoordinator.Type? {
        return items[identifer]
    }
    
    
    // MARK: - Private Interface
    private var items: [CoordinatorIdentifier: NotificationEnabledCoordinator.Type] = [:]
    
}


public protocol NotificationEnabledCoordinator: CoordinatorType {
    init?(data: [String: Any], presentationStrategy: CoordinatorPresentingStrategy)
}

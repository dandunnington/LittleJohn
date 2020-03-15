//
//  NotificationPath.swift
//  LittleJohn
//
//  Created by Dan Dunnington on 02/03/2020.
//  Copyright © 2020 Dan Dunnington. All rights reserved.
//

import Foundation
import UIKit

/**
 Represents a sequence of coordinators that the app will route to
 */
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
            guard let presentStr = json["present"] as? String else {
                throw NotificationParseError.itemJSONInvalid
            }
            
            if presentStr == "push" {
                presentationStyle = .push
            } else if presentStr == "present" {
                if let styleStr = json["presentStyle"] as? String {
                    presentationStyle = .present(style: NotificationPath.Item.getModalPresentationStyleFrom(string: styleStr) ?? .automatic)
                } else {
                    presentationStyle = .present(style: .automatic)
                }
                
            } else {
                throw NotificationParseError.itemJSONInvalid
            }
            
            guard let inputData = json["data"] as? [String: Any] else {
                throw NotificationParseError.itemJSONInvalid
            }
            self.coordinator = CoordinatorIdentifier(name: id)
            self.inputData = inputData
        }
        
        private static func getModalPresentationStyleFrom(string: String) -> UIModalPresentationStyle? {
            
            switch string {
            case "automatic": return .automatic
            case "none": return UIModalPresentationStyle.none
            case "fullScreen": return .fullScreen
            case "pageSheet": return .pageSheet
            case "formSheet": return .formSheet
            case "currentContext": return .currentContext
            case "custom": return .custom
            case "overFullScreen": return .overFullScreen
            case "overCurrentContext": return .overCurrentContext
            case "popover": return .popover
            default: return nil
            }
            
        }
        
    }
    
    public enum PresentationStyle {
        case push
        case present(style: UIModalPresentationStyle)
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
    public mutating func register(_ coordinator: NotificationEnabledCoordinator.Type, identifier: CoordinatorIdentifier? = nil) {
        items[identifier ?? coordinator.identifier] = coordinator
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
    
    static var identifier: CoordinatorIdentifier { get }
    
}

extension NotificationEnabledCoordinator {
    static var identifier: CoordinatorIdentifier {
        
        var string = String(describing: self)
        string = string.replacingOccurrences(of: "Coordinator", with: "")
        
        let firstLetter = string.dropFirst()
        string = firstLetter.lowercased() + string
        return CoordinatorIdentifier(name: string)
    }
}

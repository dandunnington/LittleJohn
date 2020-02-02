//
//  CoordinatorApp.swift
//  DDCoordinators
//
//  Created by Dan Dunnington on 01/02/2020.
//  Copyright © 2020 Dan Dunnington. All rights reserved.
//

import Foundation
import UIKit

public class CoordinatorAppContainer {
    
    private var appCoordinator: Coordinator<Bool>
    
    private init(appCoordinator: AppCoordinator) {
        self.appCoordinator = appCoordinator
    }
    
    public static func launch(_ appCoordinator: AppCoordinator) {
        
        let initialNavController = UINavigationController()
        
        
    }
    
    public typealias AppCoordinator = Coordinator<Bool>
    
}

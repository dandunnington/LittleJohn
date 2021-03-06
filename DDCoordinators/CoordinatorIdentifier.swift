//
//  CoordinatorIdentifier.swift
//  LittleJohn
//
//  Created by Dan Dunnington on 02/03/2020.
//  Copyright © 2020 Dan Dunnington. All rights reserved.
//

import Foundation

public struct CoordinatorIdentifier: Decodable, Hashable {
    
    public let name: String
    
    public init(name: String) {
        self.name = name
    }
    
    
}

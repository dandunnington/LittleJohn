//
//  ViewModelledViewControllerMock.swift
//  LittleJohnTests
//
//  Created by Dan Dunnington on 26/02/2020.
//  Copyright © 2020 Dan Dunnington. All rights reserved.
//

import Foundation
@testable import LittleJohn

class ViewModelledViewControllerMock: ViewControllerMock, ViewModelledViewControllerType {
    required init(viewModel: BaseViewModelMock) {
        self.viewModel = viewModel
    }
    
    var viewModel: BaseViewModelMock
    
    typealias ViewModel = BaseViewModelMock
    
}


class BaseViewModelMock: BaseViewModelType {
    
    var coordinator: AnyObject
    
    init(coordinator: AnyObject) {
        self.coordinator = coordinator
    }
    
    var set_isNavigationBarHidden: Bool = true
    
    var set_navTitle: String?
    
    var isNavigationBarHidden: Bool {
        return set_isNavigationBarHidden
    }
    
    var navTitle: String? {
        return set_navTitle
    }
    
    
}


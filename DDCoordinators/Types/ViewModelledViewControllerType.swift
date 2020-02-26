//
//  ViewModelledViewControllerType.swift
//  LittleJohnTests
//
//  Created by Dan Dunnington on 26/02/2020.
//  Copyright © 2020 Dan Dunnington. All rights reserved.
//

import Foundation


protocol ViewModelledViewControllerType: UIViewControllerType {
    
    associatedtype ViewModel: BaseViewModelType
    
    init(viewModel: ViewModel)
    
    var viewModel: ViewModel { get set }
    
}

protocol BaseViewModelType {
    
    var isNavigationBarHidden: Bool { get }
    
    var navTitle: String? { get }
    
}

extension ViewModelledViewController: ViewModelledViewControllerType { }

extension BaseViewModel: BaseViewModelType { }

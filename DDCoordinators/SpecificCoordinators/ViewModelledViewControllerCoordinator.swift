//
//  ViewModelledViewControllerCoordinator.swift
//  LittleJohn
//
//  Created by Dan Dunnington on 15/02/2020.
//  Copyright © 2020 Dan Dunnington. All rights reserved.
//

import Foundation

open class ViewModelledViewControllerCoordinator<DataOutput, ViewModel: BaseViewModel>: ViewControllerCoordinator<DataOutput> {
    
    /// The view model of the root view controller
    /// This can be implictly wrapped as the existence of it should be what determins existence of this object
    public weak var viewModel: ViewModel!
    
    open func makeViewModelledViewController() -> ViewModelledViewController<ViewModel> {
        fatalError("This Must be overrided")
    }
    
    override open func makeRootViewController() -> UIViewControllerType {
        let vc = makeViewModelledViewController()
        self.viewModel = vc.viewModel
        return vc
    }
    
}

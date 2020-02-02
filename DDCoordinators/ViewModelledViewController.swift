//
//  ViewModelledViewController.swift
//  CyclingTracker
//
//  Created by Dan Dunnington on 31/03/2019.
//  Copyright © 2019 Dan Dunnington. All rights reserved.
//

import Foundation
import UIKit

/**
 Base view controller
 */
open class ViewModelledViewController<ViewModel: BaseViewModel>: UIViewController {
    
    public var viewModel: ViewModel
    
    public required init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("Coder initialisation is not supported using ViewModelledViewControler")
    }
    
    // MARK: - Overrides
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.setNavigationBarHidden(viewModel.isNavigationBarHidden,
                                                          animated: animated)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
    }
    
    open override var navigationItem: UINavigationItem {
        let navItem = super.navigationItem
        navItem.title = viewModel.navTitle
        return navItem
    }
    
    open func bindViewModel() {
        
    }
    
}

open class BaseViewModel {
    
    open var isNavigationBarHidden: Bool {
        return false
    }
    
    open var navTitle: String? {
        return nil
    }
    
    public init() { }
}

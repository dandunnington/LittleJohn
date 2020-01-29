//
//  ErrorlessCoordinator.swift
//  CyclingTracker
//
//  Created by Dan Dunnington on 27/12/2019.
//  Copyright © 2019 Dan Dunnington. All rights reserved.
//

import Foundation

open class ErroringCoordinator<DataOutput, CoordinatorError: Error>: Coordinator<DataOutput> {
    
    /**
    Event to be run when the coordinator errors
     */
    open var errored: ErrorHandler = { _ in}
    
    /**
     Override this function to handle errors on the coordinator itself.
     
     This function handles errors thrown by the coordinator
     */
    open func handle(error: CoordinatorError) -> ErrorHandlingState {
        return .logged
    }
    
    /**
     Tells the coordinator to cancel itself but emit an error. When this is called the coordinator updates it's UI state in the same way as `cancel(animated)` but will pass  `error(Error)` when the coordinator completion block is run. This should only ever be called on `self` by a subclass other than in edge case circumstances
     - Parameters:
        - with: The error to emit
        - animated: Whether or not the UI should animate
     */
    final public func error(with error: CoordinatorError, animated: Bool) {
        
        switch handle(error: error) {
        case .logged:
            self.endUI(animated: animated)
        case .recovered:
            // if recovered then error has been handled internally so keep coordinator alive
            break
        case .newError(let newError):
            // send error through the handler in a recursive manner
            self.error(with: newError, animated: animated)
        }

    }

    // MARK: - Initialisers
    init(parent: AnyObject, presentingStrategy: CoordinatorPresentingStrategy, completed: CompletionBlock? = nil, cancelled: CancelBlock? = nil, errored: ErrorHandler? = nil) {
        
        self.errored = errored ?? { _ in }
        super.init(parent: parent, presentingStrategy: presentingStrategy, completed: completed, cancelled: cancelled)
    }
    
    // MARK: - Supporting Types
    
    public enum ErrorHandlingState {
        
        /// Denotes that the coordinator has handled it's own error so the app should continue execution. When this is passed the coordinator will not cancel itself
        case recovered
        
        /// Denotes that the error was logged but the application should still handle the erroring
        case logged
        
        /// Denotes that the original error was handled but a new error has been found
        case newError(_: CoordinatorError)
        
    }
    
    public typealias ErrorHandler = (CoordinatorError) -> Void
}

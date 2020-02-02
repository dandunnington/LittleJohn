import Foundation
import UIKit

/**
 A generic coordinator abstract class that handles the presentation and lifecyle of the UI
 
 The `DataOutput` generic parameter represents the data type that the coordiantor will output on completion.
 
 On deinitialisation the `willEndWith(reason:animated)` method is invoked with `cancelled` and false as it's parameters. One reason for having an inverted reference pattern is so that coordinators are deallocated when UIKit deallocates the view controllers that it holds. Deinit will often be called when the user uses the system navigation controller to pop off the coordinators root view controller from it's navigation stack.
 */
open class Coordinator<DataOutput>: NSObject, CoordinatorType {
    
    // MARK: - Overridable
    
    /**
     Called when the coordinators start method is invoked
     - Parameters:
        - animated: Whether or not the coordinator was set to animate it's UI when it was started
     */
    open func didStart(animated: Bool) {
        
    }
    
    /**
     Called just before the coordinator will complete. This should be overriden to perform actions before the coordinator ends
    - Parameters:
        - data: The data that the coordinator will complete with
        - animated: Whether or not the coordinator will animate when it ends
     */
    open func willComplete(data: DataOutput, animated: Bool) {
        
    }
    
    /**
     Called just before the coordinator will cancel. This should be overriden to perform actions before the coordinator ends
     */
    open func willCancel(animated: Bool) {
        
    }
    
    /**
     The completion block to be called when this coordinator completes. This should be used as a completion handler by the parent coordinator
     */
    public var completed: CompletionBlock
    
    /**
     The cancelled block to be called when this coordinator completes. This should be used as a completion handler by the parent coordinator
     */
    public var cancelled: CancelBlock
    
    // MARK: - Lifecycle Events
    
    /**
     Finishes the coordinator and runs the completion handlers. This method will also unwind the UI by popping the view controller or dismissing the presented navigation controller if required.
     - Parameters:
        - reason: The `EndReason` for the ending of the coordinator. If the reason is `completed` then output data will be included in this parameter
        - animated: Whether or not the UI should be animated
     */
    internal func endUI(animated: Bool) {
        switch endingStrategy {
        case .dismiss:
            self.navigationController?.dismiss(animated: animated)
        case .pop:
            guard let rootController = self.parent?.rootViewController else { return }
            self.navigationController?.popToViewController(rootController, animated: animated)
        }
    }
    
    /**
     Tells the coordinator to complete. This should only ever be called on `self` by a subclass other than in edge case circumstances
     - Parameters:
        - data: The output data to complete the coordiantor with
        - animated: Whether the UI should animate on coordinator completion
     */
    final public func complete(data: DataOutput, animated: Bool) {
        willComplete(data: data, animated: animated)
        endUI(animated: true)
        completed(data)
    }
    
    /**
    Tells the coordinator to cancel itself. This should only ever be called on `self` by a subclass other than in edge case circumstances
    - Parameters:
       - animated: Whether the UI should animate on coordinator completion
    */
    final public func cancel(animated: Bool) {
        willCancel(animated: animated)
        endUI(animated: animated)
        cancelled()
    }
        
    /**
     Tells the coordinator to start. This is when the UI changes happen and as such should always be called on the main thread
     - Parameters:
        - animated: Whether the UI should animate when the coordinator starts
        - completion: Called when the UI animations have completed (or immediately if animation is set to `false`)
     */
    final public func start(animated: Bool, completion: (()->Void)? = nil) {
        
        // create navigation controller
        var navigationController: UINavigationController
        switch presentingStrategy {
        case .present, .none:
            navigationController = UINavigationController()
        case .pushNavigationController(navigationController: let navController):
            navigationController = navController
        case .pushFromCoordinator(let coordinator):
            if let navController = coordinator._strongNavigationController {
                navigationController = navController
            } else if let navController = coordinator.navigationController {
                navigationController = navController
            } else {
                return
            }
        }
            
        self.endingStrategy = presentingStrategy?.endingStrategy ?? .dismiss
        
        self._strongNavigationController = navigationController
        // Display UI
        displayUI(animated: animated)
            
        // deallocate navController
        self._strongNavigationController = nil
        
        didStart(animated: animated)
    }
    
    internal func displayUI(animated: Bool) {
        
    }
    
    public var rootViewController: UIViewController? {
        return nil
    }
    
    internal var endingStrategy: CoordinatorEndingStrategy = .dismiss
    
    public var _strongNavigationController: UINavigationController?
    
     //MARK: - Inintialisers
    /**
     Designated initialiser for the coordinator class
     - Parameters:
        - parent: The parent object of this coordinator. This class will maintain a strong reference to the object passed
        - presentingStrategy: The strategy used for presenting this view controller. This may not be used if the coordinator instantly delegates it's state to a child
        - completion: Run once the coordinator has completed and contains the output data if applicable
     */
    public init(presentingStrategy: CoordinatorPresentingStrategy, completed: CompletionBlock? = nil, cancelled: CancelBlock? = nil) {
        
        self.completed = completed ?? { _ in }
        self.cancelled = cancelled ?? { }
        self.presentingStrategy = presentingStrategy
        super.init()
    }
    
    deinit {
        
        // could do with finding animation boolean but presume no animation
        willCancel(animated: false)
        
        // on deinit notify the parent coordinator that the coordinator was cancelled
        cancelled()
    }
    
    
    
    // MARK: - Private Interface
    
    /**
     This coordinators parent object
     */
    public var parent: CoordinatorType?
    
    // MARK: - Manually Managed in Memory    
    internal var presentingStrategy: CoordinatorPresentingStrategy?
    
    public var children: [WeakCoordinatorType] = []
    
    // MARK: - Supporting Types
    public typealias CompletionBlock = (DataOutput) -> Void
    
    public typealias CancelBlock = () -> Void

}



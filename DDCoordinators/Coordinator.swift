import Foundation
import UIKit

/**
 A generic coordinator abstract class that handles the presentation and lifecyle of the UI. You should not subclass this directly but instead subclass the `DelegatingCoordinator` and `ViewControllerCoordinator` subclasses
 
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
     All subclasses should override this method. This method handles the displaying of UI and is called during the coordinators `start()` method.
     - Parameters:
        - animated: Whether or not the UI should animate when it is displayed
     */
    internal func displayUI(animated: Bool) {
        
    }
    
    /**
     The completion block to be called when this coordinator completes. This should be used as a completion handler by the parent coordinator
     */
    public var completed: CompletionBlock
    
    /**
     The cancelled block to be called when this coordinator completes. This should be used as a completion handler by the parent coordinator
     */
    public var cancelled: CancelBlock
    
    
    // MARK: - Public Final Interface
    
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
        self.endingStrategy = presentingStrategy.endingStrategy
        super.init()
    }
    
    deinit {
        
        // could do with finding animation boolean but presume no animation
        willCancel(animated: false)
        
        // on deinit notify the parent coordinator that the coordinator was cancelled
        cancelled()
    }
    
    
    // MARK: - Internal Interface
    internal var presentingStrategy: CoordinatorPresentingStrategy?
    
    internal var endingStrategy: CoordinatorEndingStrategy = .dismiss
    
    /**
     Finishes the coordinator and runs the completion handlers. This method will also unwind the UI by popping the view controller or dismissing the presented navigation controller if required.
     - Parameters:
        - reason: The `EndReason` for the ending of the coordinator. If the reason is `completed` then output data will be included in this parameter
        - animated: Whether or not the UI should be animated
     */
    internal final func endUI(animated: Bool) {
        switch endingStrategy {
        case .dismiss:
            self.navigationController?.dismiss(animated: animated)
        case .pop:
            guard let rootController = self.parent?.rootViewController else { return }
            self.navigationController?.popToViewControllerType(rootController, animated: animated)
        case .none:
            break
        }
    }
    
    // MARK: - Supporting Types
    public typealias CompletionBlock = (DataOutput) -> Void
    
    public typealias CancelBlock = () -> Void
    
    // MARK: - Public CoordinatorType conformance
    
    public var rootViewController: UIViewControllerType? {
        return nil
    }
    
    /**
     Tells the coordinator to start. This is when the UI changes happen and as such should always be called on the main thread
     - Parameters:
        - animated: Whether the UI should animate when the coordinator starts
        - completion: Called when the UI animations have completed (or immediately if animation is set to `false`)
     */
    final public func start(animated: Bool, completion: (()->Void)? = nil) {
        
        // create navigation controller
        var navigationController: UINavigationControllerType
        switch presentingStrategy {
        case .present, .tab, .none, .presentFromCoordinator:
            navigationController = createNavController()
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
        
        self._strongNavigationController = navigationController
        // Display UI
        displayUI(animated: animated)
            
        // deallocate navController and presenting strategy
        switch presentingStrategy {
        case .tab:
            break
        default:
            self._strongNavigationController = nil
        }
        
        self.presentingStrategy = nil
        
        didStart(animated: animated)
    }
    
    final public func deallocateStrongNavController() {
        self._strongNavigationController = nil
    }

    /// A temporary strong navigation controller. This is used to retain a navigation controller before it has been put in the view hierachy
    /// This is deallocated at the end of the start method so will most of the time be nil to avoid retain cycles
    public var _strongNavigationController: UINavigationControllerType?
    
    /**
     This coordinators parent object
     */
    public var parent: CoordinatorType?
    
    // MARK: - Internal Test Interface
    internal var createNavController: () -> UINavigationControllerType = {
        return UINavigationController()
    }

}

/// Issues in Xcode compiler when using Void for specialising coordinators that do not return anything (abort trap 6)
/// This should be used instead of Void
public typealias NoReturn = Bool

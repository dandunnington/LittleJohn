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
     This **must** be overriden to return the `CoordinatorStartStrategy` of the specialised subclass. If this method is not overriden and this method accessed then a fatal error will occur.
     - Returns: The `CoordinatorStartStrategy` that the app should employ when it begins
     */
    open func makeStartStrategy() -> CoordinatorStartStrategy {
        fatalError("Method must be overriden")
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
        
        switch startStrategy {
        case .viewController(let initialViewController):
            switch presentingStrategy {
            case .present:
                self.navigationController?.dismiss(animated: animated)
            case .pushNavigationController, .pushFromCoordinator:
                self.navigationController?.popToViewController(initialViewController, animated: animated)
                self.navigationController?.popViewController(animated: animated)
            }
        case .childCoordinator(_):
            
            // if this coordinator has delegated responsibility to a child coordinator then that child will
            // have handled the UI state
            break
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
        case .present:
            navigationController = UINavigationController()
        case .pushNavigationController(navigationController: let navController):
            navigationController = navController
        case .pushFromCoordinator(let coordinator):
            
            // TODO Coordinator error
            guard let passedNavController = coordinator.navigationController else { return }
            navigationController = passedNavController
        }
        self.navigationController = navigationController
        
        // Display UI
        switch self.startStrategy {
        case .childCoordinator(let coordinator):
            coordinator.start(animated: false, completion: nil)
            
        case .viewController(let initialViewController):
        
            switch presentingStrategy {
            case .pushNavigationController, .pushFromCoordinator:
                navigationController.pushViewController(initialViewController, animated: animated)
            case .present(modalConfig: let config):
                navigationController.pushViewController(initialViewController, animated: false)
                config.presentingController.present(config.configureForPresentation(controller: navigationController),
                                                    animated: animated,
                                                    completion: completion)
            }
        }
        
        didStart(animated: animated)
    }
    
     //MARK: - Inintialisers
    /**
     Designated initialiser for the coordinator class
     - Parameters:
        - parent: The parent object of this coordinator. This class will maintain a strong reference to the object passed
        - presentingStrategy: The strategy used for presenting this view controller. This may not be used if the coordinator instantly delegates it's state to a child
        - completion: Run once the coordinator has completed and contains the output data if applicable
     */
    public init(parent: AnyObject, presentingStrategy: CoordinatorPresentingStrategy, completed: CompletionBlock? = nil, cancelled: CancelBlock? = nil) {
        
        self.presentingStrategy = presentingStrategy
        self.parent = parent
        self.completed = completed ?? { _ in }
        self.cancelled = cancelled ?? { }
        super.init()
    }
    
    deinit {
        
        // could do with finding animation boolean but presume no animation
        willCancel(animated: false)
        
        // on deinit notify the parent coordinator that the coordinator was cancelled
        cancelled()
    }
    
    public init(parent: AnyObject, navigationController: UINavigationController, completion: @escaping CompletionBlock, cancelled: @escaping CancelBlock) {
        self.parent = parent
        self.navigationController = navigationController
        self.presentingStrategy = .pushNavigationController(navigationController)
        self.completed = completion
        self.cancelled = cancelled
        super.init()
    }
    
    
    // MARK: - Private Interface
    
    /**
     This coordinators parent object
     */
    private(set) var parent: AnyObject
    
    /**
     Defines how the coordinator's `initialViewController` is displayed
     */
    private var presentingStrategy: CoordinatorPresentingStrategy
    
    /**
     Defines what happens  when the start method is called
     */
     internal private(set) lazy var startStrategy: CoordinatorStartStrategy = makeStartStrategy()
    
    /**
     The initial navigation controller for this coordinator
     */
    public private(set) weak var navigationController: UINavigationController?
    
    // MARK: - Supporting Types
    public typealias CompletionBlock = (DataOutput) -> Void
    
    public typealias CancelBlock = () -> Void

}

/**
 A non generic coordinator base type for coordiantors.
 
 All coordinators should conform to this protocol as all coordinators should conform to the `Coordinator` base class
 */
public protocol CoordinatorType: AnyObject {
    
    func start(animated: Bool, completion: (()->Void)?)
    
    var navigationController: UINavigationController? { get }

}

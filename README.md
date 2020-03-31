# Little John

A general purpose iOS Swift coordinator framework that solves the deallocation problem and allows declarative deeplinking into the app from notifications

Example app available at: https://github.com/dandunnington/Pizzr

## Contents
- [Features](#Features)
- [Overall Principles](#overall-principles)
- [ViewModelledViewControllerCoordinator](#wiewmodelledviewcontrollercoordinator)
- [ViewControllerCoordinator](#viewcontrollercoordinator)
- [DelegatingCoordinator](#delegatingcoordinator)
- [ViewControllerCoordinator](#viewcontrollercoordinator)
- [Managing Child Coordinators](#managing-child-coordinators)
- [Notifications](#notifications)

## Features
- Coordinators will deallocate themselves when their associated view controllers have been deallocated (eg. popped off a UINavgiationController view controller stack)
- Push users to a specific coordinator from a push notifcation without the need for an app update
- Coordinators can output strongly typed data on completion
- All UI presentation is handled by the framework. This allows for a more declarative approach to managing the roots of the view hierachy
- Delegating coordinators with no view controllers attached can delegate down to a child coordinator when started

## Overall Principles

The below assumes you are familiar with the coordinator pattern in iOS swift. There are many good tutorials on this pattern so the basics of coordinators will not be covered here.

- All coordinators take a generic parameter. This is the output value of the coordinator
- All coordinators contain a navigation controller.
- All events go through the view model class and the view model talks to the coordinator via a protocol. The view controller never talks to the coordinator directly.
- All view controller interaction is handled via the LittleJohn framework. This includes presenting and dismissing view controllers 

There are 2 main types of coordinators. These are `DelegatingCoordinator` and `ViewModelledViewControllerCoordinator`. Both types of coordinators take a generic parameter which refers to the return type of the coordinator. Please note that there are issues with specialising coordinators with type `Void`. If you get compiler issues you should use the type `NoReturn

## ViewModelledViewControllerCoordinator

When started this coordinator shows a `ViewModelledViewController` instance.

You must strongly reference this coordinator from the associated view model. Since LittleJohn uses the inverse coordinator pattern all coordinators are ultimately retained by UIKit.  `ViewModelledViewController` strongly references it's `ViewModel` value so, in order to access coordinator methods, view model should retain the coordinator. The memory graph should look like this (where -> denotes a strong reference)

`ViewModelledViewController` -> `ViewModelledViewController` -> `ViewModelledViewControllerCoordinator`

### Configuration

To create the `ViewModelledViewController` instance you must override the `makeViewModelledViewController()` method. You must always override this method and not caller `super.makeViewModelledViewController()`. Doing either of these will result in a run-time error. You must also specialise the coordinator with the view model type that subclasses `BaseViewModel` along with the output type.

From the [Pizzr](https://github.com/dandunnington/Pizzr) app:

```swift
class MyPizzasCoordinator: ViewModelledViewControllerCoordinator<Bool, MyPizzasViewModel> {
    
    // MARK: - Overrides
    override func makeViewModelledViewController() -> ViewModelledViewController<MyPizzasViewModel> {
        return MyPizzasViewController(viewModel: MyPizzasViewModel(coordinator: self))
    }
    
}
```

Note that you should not maintain a strong reference to this view controller or it's view model. `ViewModelledViewControllerCoordinator` contains the `viewModel` property of type `ViewModel?` (the generic view model paramter). This is weakly referenced.

## DelegatingCoordinator

These coordinators do not directly own a view controller but instead instantly delegate this responsibility to a child view controller. A good example for when this coordinator would be appropriate is an apps top level coordintor traditionally known as the `AppCoordinator`.

If your app has a login feature then you may wish to perfrom some logic in here to decide whether to show the main app (the user is logged in) or show a login screen. It makes sense to divide the login or main app's logic functions into there own respective coordinators.

### Configuration

In order to create the delegated coordinator you should override the `makeDelegatingCoordinator()` method. Note that you should not store a strong reference to it since this the delegated coordinator becomes a child coordinator of this delegating coordinator and hence has a strong reference to it. You should always use the `pushFromCoordinator` presenting strategy case passing `self` as the parent. 

From the [Pizzr](https://github.com/dandunnington/Pizzr) app:

``` swift

class AppCoordinator: DelegatingCoordinator<Bool> {
    ...
    
    override func makeDelegatingCoordinator() -> CoordinatorType {
        MainTabCoordinator(presentingStrategy: .pushFromCoordinator(self))
    }
    ...
}
```
## ViewControllerCoordinator

This is the same as `ViewModelledViewControllerCoordinator` except it allows you to use a `UIViewController` subclass directly instead of a `UIViewController` subclass. This should only be used to support existing code as it breaks a number of principles followed by this framework

## Managing Child Coordinators

All coordinators can start a child. Every coordinator has the method `startChild(animated:_:)`.  Typically this is done inside a view model delegate method of a coordinator. A user might tap a button and then this will trigger the coordinator to launch a new child coordinator


From the [Pizzr](https://github.com/dandunnington/Pizzr) app:
```swift
extension MyPizzasCoordinator: MyPizzaViewModelDelegate {
    func addTapped(_ viewModel: MyPizzasViewModel) {
        
        startChild(animated: true, AddPizzaCoordinator(
            presentingStrategy: .pushFromCoordinator(self),
            completed: viewModel.addPizza(pizza:),
            cancelled: nil
        ))
    }
}
```

In the above snippet you will see that this basic `AddPizzaCoordinator`  initialiser takes 3 parameters. These are 3 parameters that need to be passed to every coordinator. You are free to add other application specific parameters to subclass initialisers but initialisers should always take these 3 parameter in and pass them to `super.init`.

### Presentation Strategy
This tells the frame work how it should show the child coordinators view.

The two main cases are as follows:
- `pushFromCoordinator(_:)`
- `presentFromCoordinator(_:)`

These two cases take in a parent coordinator as an associated type. This will nearly always be `self`

### Handlers
- `completed` - This is the completion handler for the coordinator. When the coordinator completes, this handler is run. It passes the coordinators output data which is strongly type with the type `DataOutput`. This is the type that the coordinator is specialised with.

- `cancelled` - This is run when the coordinator has deemed to have been cancelled. This is can be run explicitly when the user taps a close button or triggered automatically when the coordinator deallocates. The deallocation scenario will happen when UIKit removes the last view controller associated with a coordinator from the navigation stack or when a modal is dismissed. Since UIKit is ultimately retaining the coordinator ARC will determine that there are no longer any references to the coordiantor and hence deinialise it called `deinit` on the coordinator and triggering `cancelled`.

## Notifications

Since LittleJohn adopts a very strict approach when it comes to coordinator hierachy and presentation we are able to set up simple flows completely declaritively. This comes in very handy when deeplinking/routing when tapping on a notification. Below example of a notification a path in JSON format:

```json
{
    "coordinatorPath": {
        "id": "test",
        "items": [
            {
                "id": "addPizza",
                "present": "present",
                "presentationStyle": "automatic",
                "data": { }
            },
            {
                "id": "addPizza",
                "present": "push",
                "data": {
                    "name": "Passed Pizza",
                    "toppings": ["pepperoni", "peppers"],
                    "cheese": "stilton"
                }
            }
        ]
    }
}

```

### Protocol

Conforming to the `NotificationEnabledCoordinator` protocol provides the functionality needed to use the above JSON. It has the following delcaration:
```
public protocol NotificationEnabledCoordinator: CoordinatorType {
    
    init?(data: [String: Any], presentationStrategy: CoordinatorPresentingStrategy)
    
    static var identifier: CoordinatorIdentifier { get }
    
}
```
The `identifier` get-only variable is a simple wrapped `String` that allows the system to load the coordinator at runtime. This is matched to the `identifier` field in the JSON to load a coordinator. The `present` field can have the value of `push` or `present` and either pushes the root view controller onto the navigation controller or presents it (within a navigation controller) respectively.

The initialiser allows the system to instantiate the coordinator from a JSON object. The `data` parameter is all the necessary JSON data needed to instantiate all your custom properties on the coordinator. The `presentationStrategy` parameter refers to whether the coordinator's view controller is pushed onto it's parents. 

### Registering Coordinators & AppCoordinatorType

In order to instatiate a coordinator class it must be registered much like cells need to be registered in a `UITableView`.  The `NotficationCoordinatorRegister` class keeps track of coordinators that are registered for notifications.

Conforming to the `AppCoordinatorType` allows for a coordinator to be the route of a coordinator sequence. This protocol has a method that allows the implementation to register coordinators from a  `NotficationCoordinatorRegister`.

In [Pizzr](https://github.com/dandunnington/Pizzr) the main `AppCoordinator` class conforms to `AppCoordinatorType`. This will be the case in most apps. Registering of the coordinators in done in the `didStart` method. Unlike in `UITableView` you do not need to specify an identifier. In LittleJohn coordinators define their own identifiers.

```swift
class AppCoordinator: DelegatingCoordinator<Bool>, AppCoordinatorType {
    ...
    override func didStart(animated: Bool) {
        super.didStart(animated: animated)
        registerNotificationEnabledCoordinators(container: NotficationCoordinatorRegister.shared)
    }
    
    internal func registerNotificationEnabledCoordinators(container: NotficationCoordinatorRegister) {
        container.register(AddPizzaCoordinator.self)
    }
    ...
}

```
Actioning a coordinator sequence then becomes very simple. Inside your notification handler, simply pass the notification JSON as shown:

```swift
self.appCoordinator?.performNotificationRoute(userInfo: userInfo)
```

![Little John](https://raw.githubusercontent.com/Alamofire/Alamofire/master/alamofire.png)

A general purpose iOS Swift coordinator framework that solves the deallocation problem, plays nicely with UIKit along with other features to minimise boiler plate code.

Example app available at : https://github.com/dandunnington/DDCoordinatorExampleApp

## Features
- Coordinators will deallocate themselves when their associated view controllers have been deallocated (eg. popped off a UINavgiationController view controller stack)
- Coordinators can output strongly typed data on completion
- Removal of a view controller for the view hierachy is handled based on presentation
- Delegating coordinators with no view controllers attached can delegate down to a child coordinator when started

## Usage

### ViewModelledViewControllerCoordinator

Subclass `ViewModelledViewControllerCoordinator` passing the output type and view model type.
```swift
class MyPizzasCoordinator: ViewModelledViewControllerCoordinator<Bool, MyPizzasViewModel> {
    
    // MARK: - Overrides
    override func makeViewModelledViewController() -> ViewModelledViewController<MyPizzasViewModel> {
        return MyPizzasViewController(viewModel: MyPizzasViewModel(coordinator: self))
    }
    
}
```

Conform to the view model delegate and use the `startChild(animated:_:)` method to start the `AddPizzaCoordinator`.

On completion we tell the root view model (strongly typed `viewModel` property on `self`) to add the passed pizza. The pizza is passed back via the completion block.
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

import Vapor
import SlackKit

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "It works" example
    router.get { req -> String in
        return "Navigate to the route '/start' to start Teddy. BUT ONLY NAVIGATE TO IT ONCE!"
    }
    
    // Basic "Hello, world!" example
    router.get("start") { req -> String in
        Teddy.shared.setup()
        return "Teddy started! DO NOT refresh, otherwise teddy will be started twice!"
    }

    // Example of configuring a controller
    let todoController = TodoController()
    router.get("todos", use: todoController.index)
    router.post("todos", use: todoController.create)
    router.delete("todos", Todo.parameter, use: todoController.delete)
}

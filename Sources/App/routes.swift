import Vapor
import SlackKit

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "It works" example
    router.get { req -> String in

        guard let token = Environment.get("SLACK_TOKEN")
        else { fatalError("No Slack token found!") }

        let _ = Threddy(token: token)

        return "Treddy started?"
    }
    
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }

    // Example of configuring a controller
    let todoController = TodoController()
    router.get("todos", use: todoController.index)
    router.post("todos", use: todoController.create)
    router.delete("todos", Todo.parameter, use: todoController.delete)
}


class Threddy {

    let bot: SlackKit

    init(token: String) {
        bot = SlackKit()
        bot.addRTMBotWithAPIToken(token)
        bot.addWebAPIAccessWithToken(token)
        bot.notificationForEvent(.message) { (event, connection) in
            guard
                let msg = event.message,
                let id = connection?.client?.authenticatedUser?.id,
                msg.text?.contains(id) == true
            else { return }

            self.handleMessage(msg)
        }

    }

    private func handleMessage(_ message: Message) {
        if
            let timestamp = message.ts,
            let channel = message.channel,
            let username = message.username,
            username == "Morad Copy"
        {
            self.bot.webAPI?.sendThreadedMessage(
                channel: channel,
                thread: timestamp,
                text: """
                Thread engage!
                """,
                success: { (timestamp, channel) in },
                failure: { (error) in
                    print("the error: \(error)")
            })
        }
    }

}

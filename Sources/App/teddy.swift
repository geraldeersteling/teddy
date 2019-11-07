//
//  teddy.swift
//  App
//
//  Created by Gerald Eersteling on 07/11/2019.
//

import Foundation
import Vapor
import SlackKit

class Teddy {
    enum Bots {
        case Teddy
        case Morad

        func id() -> String {
            switch self {
                case .Teddy:
                    return "BPW80F6M7"
                case .Morad:
                    return "BQATV5Z8F"
            }
        }
    }

    static let shared = Teddy()
    private let bot: SlackKit
    private var didSetup = false

    private init() {
        bot = SlackKit()
    }

    func setup() {
        guard !didSetup
        else { return }
        
        didSetup = true

        guard let token = Environment.get("SLACK_BOT_TOKEN")
        else { fatalError("No Slack bot token found!") }

        bot.addRTMBotWithAPIToken(token)
        bot.addWebAPIAccessWithToken(token)
        bot.notificationForEvent(.message) { (event, connection) in
            guard
                let msg = event.message
                //let id = connection?.client?.authenticatedUser?.id,
                //msg.text?.contains(id) == false
            else { return }

            self.handleMessage(msg)
        }
    }

    func isMessage(_ message: Message, sendBy bot: Bots) -> Bool {
        guard
            let botID = message.botID,
            botID == bot.id()
        else { return false }
        return true
    }

    func isThreadReply(_ message: Message) -> Bool {
        guard
            let ts = message.ts,
            let thread_ts = message.threadTs
        else { return false }
        return ts != thread_ts
    }

    private func handleMessage(_ message: Message) {
        // We only handle things that have common sense
        guard
            let originalChannel = message.channel,
            let originalTs = message.ts,
            let originalText = message.text
        else { return }

        // We don't want to create an infinite loop whenever Teddy messages something
        guard !isMessage(message, sendBy: .Teddy)
        else { return }

        guard !isThreadReply(message)
        else { return }

        // Regular messages can only be send by Morad
        guard isMessage(message, sendBy: .Morad)
        else {
            if let user = message.user {
                let text = """
                Please use threads to answer Morad: Here is what I deleted:
                ----

                *\(originalText)*

                """

                bot.webAPI?.sendEphemeral(channel: originalChannel,
                                          text: text,
                                          user: user,
                                          success: { _ in self.delete(message: message) },
                                          failure: { error in print("what now...\(error)") })
            }
            return
        }

        let text = """
        Thread locked, fire away!
        """
        sendText(text, usingMessage: message, asThread: true)
    }

    private func sendText(_ text: String,
                          usingMessage message: Message,
                          asThread: Bool = false,
                          success: (((ts: String?, channel: String?)) -> Void)? = nil,
                          failure: ((_ error: SlackError) -> Void?)? = nil) {
        guard
            let timestamp = message.ts,
            let channel = message.channel
        else { return }

        bot.webAPI?.sendThreadedMessage(
            channel: channel,
            thread: asThread ? timestamp : "",
            text: text,
            success: success,
            failure: { (error) in
                if let fail = failure {
                    fail(error)
                }
        })
    }

    private func delete(message: Message) {
        guard
            let timestamp = message.ts,
            let channel = message.channel
        else { return }

        // Temporary use the OAuth user token instead to delete the message
        guard let user_token = Environment.get("SLACK_USER_TOKEN")
        else { fatalError("No Slack user token found!") }

        bot.addWebAPIAccessWithToken(user_token)
        bot.webAPI?.deleteMessage(channel: channel,
                                  ts: timestamp,
                                  success: nil,
                                  failure: { error in print("de fuk: \(error)")})

        // Then revert to the Bot token afterwards
        guard let bot_token = Environment.get("SLACK_BOT_TOKEN")
        else { fatalError("No Slack bot token found!") }
        bot.addWebAPIAccessWithToken(bot_token)
    }

}


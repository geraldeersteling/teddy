# Configuration

Teddy needs two tokens in the ENV variables:

- A bot token; `SLACK_BOT_TOKEN`
- A user token: `SLACK_USER_TOKEN`
	- The user installing Teddy will be the one which is wired to this token

## Adding the configurations to Vapor

To add the tokens to the Vapor cloud use:

`vapor cloud config modify SLACK_BOT_TOKEN=TOKEN_BOT SLACK_USER_TOKEN=TOKEN_USER`

> Substitute both `TOKEN_BOT` and `TOKEN_USER` with the respective tokens from Slack

# Deploying

Obviously you need to manage your own Vapor cloud, you can use `vapor cloud deploy` to deploy Teddy to the environment of your choosing.
The only requirement is adding this git repo's SSH as hosting.

# Starting and stopping Teddy

By navigating to `/start` you can start Teddy. **But only do this once, otherwise you will start Teddy multiple times!**

The only way to stop Teddy as of now is to stop the application's environment by turning the replica's to 0. You can do this with the command: `vapor cloud deploy --replicas=0`.

To turn Teddy back on you need to set the replicas to 1 and go to `/start` again.
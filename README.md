Slack Bot Rootme
================

Description
-----------
A [Slack](https://slack.com/) bot to display [root-me](http://www.root-me.org/) ranking of the team members.


Commands
--------
* `rootme`: without command, the default is to print a help message
* `rootme ranking`: display the ranking of all the users registered
* `rootme add slack_pseudo rootme_pseudo`: register a user for the ranking
    - `slack_pseudo`: pseudo of the user on Slack
    - `rootme_pseudo`: pseudo of that same user on root-me.org
* `rootme remove slack_pseudo`: stop following a user (__NOT IMPLEMENTED YET__)


Setup
-----
### On slack.com

1. create a Slack bot [here](https://ms-sis.slack.com/services/new/bot), choose `rootme` for the name
2. note the API token
3. optionnal: in the "Customize Icon" section, click "Choose an emoji" and select `:skull_and_crossbones:`, it's similar to root-me.org's icon

### On your server

1. clone this repository on your server
2. run `bundle install` to install dependencies
3. run the bot: `SLACK_API_TOKEN=[YOUR TOKEN HERE] bundle exec ruby rootmebot.rb`

### In your Slack client

1. invite the bot in the channel you want it in: `/invite rootme`
2. you can now send commands to the bot! See "Commands" section above.


Technical details
-----------------
Uses the gem [slack-ruby-bot](https://github.com/dblock/slack-ruby-bot).

Unfortunately, root-me.org doesn't provide an API, so the data is found with HTML parsing.


License
-------
GPL

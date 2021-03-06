module RootmeBot
  module Rootme
    def self.add_user slack_pseudo, rootme_pseudo
      db = RootmeBot::Database.instance

      # check if user already exist
      if db.get_user(slack_pseudo, rootme_pseudo) != nil
        return "#{slack_pseudo} already registered! (known on root-me as #{rootme_pseudo})"
      end

      # create user object
      user = {
        slack_pseudo: slack_pseudo,
        rootme_pseudo: rootme_pseudo
      }

      # request to root-me to get his rank, etc
      begin
        user.merge! RootmeBot::Web.score(rootme_pseudo)
      rescue RootmeBot::Web::RootmeRequestError => error
        return error.message
      rescue RootmeBot::Web::RootmeParsingError => error
        return error.message
      end

      # save user in database
      begin
        db.add_user user
      rescue RootmeBot::Database::RootmeDatabaseWriteError
        return "Error: can't write to database. User not registered."
      end

      # generate success message
      message  = "Added #{user[:slack_pseudo]}, known on root-me as #{user[:rootme_pseudo]}\n"
      message += "#{user[:score]} points, "
      message += "place #{user[:place]} (#{user[:rank]}), "
      message += "validated #{user[:ratio]}"

      return message
    end

    def self.remove_user slack_pseudo
      db = RootmeBot::Database.instance

      user = db.get_user slack_pseudo
      return "Error: user #{slack_pseudo} not found in bot database." if user == nil

      db.remove_user slack_pseudo
      return "User #{slack_pseudo} successfully unregistered."
    end

    def self.ranking
      db = RootmeBot::Database.instance
      users = db.get_users

      return "No user registered. Add users with `add`!" if users.size == 0

      # we sort the users based on the number of points on root-me.org
      users.sort! { |a,b| a[:score] <=> b[:score] }
      users.reverse!

      # we create the message and return it
      # first, for each user, starting from best ranked,
      # we dislay a line with score, rank, etc...
      message = "Ranking:\n"
      users.each_with_index do |user, index|
        message += "#{index+1}. #{user[:slack_pseudo]} (aka #{user[:rootme_pseudo]})"
        message += " — #{user[:score]} points — place #{user[:place]} — completed #{user[:ratio]}"
        message += "\n"
      end

      # last, we add a summary line like "In the team, there is 2 hackers, 3 lamers, 1 newbie."
      ranks = HashWithIndifferentAccess.new({ elite: 0, hacker: 0, programmer: 0, lamer: 0, newbie: 0 })
      users.each do |user|
        ranks[user[:rank]] += 1
      end

      message += "In the team, there is "
      comma = false
      ranks.each do |rank, number|
        if number > 0
          message += ", " if comma
          message += "#{number} #{rank}"
          message += "s" if number > 1
          comma = true if !comma
        end
      end
      message += "."

      return message
    end
  end
end

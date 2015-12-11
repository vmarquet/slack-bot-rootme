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

      # we create the message
      message = "Ranking:\n"
      users.each_with_index do |user, index|
        message += "#{index+1}. #{user[:slack_pseudo]} (aka #{user[:rootme_pseudo]})"
        message += " — #{user[:score]} points — place #{user[:place]} — completed #{user[:ratio]}"
        message += "\n"
      end

      return message
    end
  end
end

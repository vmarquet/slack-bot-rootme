module RootmeBot
  class Database
    include Singleton

    DATABASE_PATH = "db.json"

    def initialize
      begin
        File.open(DATABASE_PATH, "r") do |f_in|
          @users = HashWithIndifferentAccess.new(JSON.load(f_in))[:users]
        end
      rescue Errno::ENOENT  # "No such file or directory"
        @users = []
      end
    end

    def save
      begin
        File.open(DATABASE_PATH, "w") do |f_out|
          JSON.dump({ users: @users }, f_out)
        end
      rescue Errno::EACCES  # "Permission denied"
        raise RootmeDatabaseWriteError
      end
    end

    def add_user user
      @users.append user
      save
    end

    def get_user slack_pseudo=nil, rootme_pseudo=nil
      if slack_pseudo != nil && rootme_pseudo != nil
        user = @users.reject { |u| u[:slack_pseudo] != slack_pseudo || u[:rootme_pseudo] != rootme_pseudo }
        return user[0]
      elsif slack_pseudo != nil
        user = @users.reject { |u| u[:slack_pseudo] != slack_pseudo }
        return user[0]
      elsif rootme_pseudo != nil
        user = @users.reject { |u| u[:rootme_pseudo] != slack_pseudo }
        return user[0]
      end
      
      return nil
    end

    def get_users
      @users
    end

    def remove_user slack_pseudo
      @users = @users.select { |user| user[:slack_pseudo] != slack_pseudo }
      save
    end
  end
end

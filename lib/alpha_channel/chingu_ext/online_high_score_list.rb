module Chingu
  # Reduced the hardcoded timeouts.
  class OnlineHighScoreList
    def initialize(options = {})
      @limit = options[:limit] || 100
      @sort_on = options[:sort_on] || :score
      @login = options[:login] || options[:user]
      @password = options[:password]
      @game_id = options[:game_id]

      begin
        require 'rest_client'
        require 'crack/xml'
      rescue
        puts "HighScoreList requires 2 gems, please install with:"
        puts "gem install rest-client"
        puts "gem install crack"
        exit
      end

      @resource = RestClient::Resource.new("http://api.gamercv.com/games/#{@game_id}/high_scores",
                                           :user => @login, :password => @password, :timeout => 3, :open_timeout => 2)

      @high_scores = Array.new  # Keeping a local copy in a ruby array
    end
  end
end
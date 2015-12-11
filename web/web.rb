module RootmeBot
  module Web
    def self.url username, lang="en"
      languages = ["de", "en", "fr"]
      lang = "en" if !languages.include?(lang)
      "http://www.root-me.org/#{username}?inc=score&lang=#{lang}"
    end

    def self.score username, lang="en"
      languages = ["de", "en", "fr"]
      lang = "en" if !languages.include?(lang)

      http = Net::HTTP.new("www.root-me.org", 80)
      request = Net::HTTP::Get.new("/#{username}?inc=score&lang=#{lang}")

      begin
        response = http.request(request)
      rescue StandardError
        raise RootmeRequestError, "Error in connection to root-me.org (Net::HTTP request failed)"
      end

      code = response.code.to_i
      if code != 200
        msg = "Error in request to root-me.org: #{response.code} #{response.message}."

        msg += "\nWarning, the root-me pseudo is case sensitive." if code == 301
        
        if code == 404
          msg += "\nNo page for that username.\nTip: the username must be the one"
          msg += " that shows up in the adress bar on your personal page."
        end
        
        msg += "\nUser not registered."
        raise RootmeRequestError, msg
      end

      begin
        html = Nokogiri::HTML(response.body)
        main = html.css("main")  # get the <main> ... </main>
        div_top = main.css("div")[0]  # get the <div class="small-12 columns"> ... </div>
        list_top = div_top.css("ul")  # the <ul> with the Challenges, Place and Rank items </ul>
        span_challenges = list_top.css("li")[0].css("span")[0]
        span_place = list_top.css("li")[1].css("span")[0]
        span_rank = list_top.css("li")[2].css("span")[0]

        # get score in the "Challenges" span, for example in "Challenges : 1775 Points  86/205"
        match = span_challenges.text.match(/\D*([0-9]*)\D*([0-9]*\/[0-9]*)\D*/)
        score, ratio = match[1].to_i, match[2]

        # get "Place", for example in "Place : 448/21114"
        place = span_place.text.match(/\D*([0-9]*)\D*([0-9]*)\D*/)[1]

        # get "Rank", for example in "Rank : lamer"
        rank = span_rank.text.match(/\W*([a-z]*)\W*/)[1]
      rescue Error
        raise RootmeParsingError, "Error: failed parsing root-me HTML code"
      end

      return {
        score: score,
        ratio: ratio,
        place: place,
        rank: rank,
        last_update: Time.now.to_s
      }
    end
  end
end

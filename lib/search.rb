require "net/http"
require "uri"

module Search
  class Base
    def self.search(params)
      _results(params)
    end
    private
    def self._results(params)
      uri = URI.parse(url)
      uri.query = URI.encode_www_form( params )
      Net::HTTP.get(uri)
    end
  end
  class Google < Base
    def self.url
      'http://www.google.com/search'
    end
  end
  class Yahoo < Base
    def self.url
      'http://search.yahoo.com/search'
    end
  end
  class A2ma < Base
    def self.url
      Rails.application.config.ad_server.send(Rails.env).url + "/search/ads.json"
    end
    def self.results
      SearchResults::A2MA
    end
  end
end
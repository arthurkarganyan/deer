module Deer
  class RedirectError < StandardError
    attr_reader :url

    def initialize(url)
      @url = url
      super
    end

    def to_rack_response
      [302, {'Location' => url}, []]
    end
  end
end

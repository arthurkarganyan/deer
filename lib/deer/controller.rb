module Deer
  class Controller
    include ReqTools
    attr_reader :req

    def initialize(req)
      @req = req
    end

    def set_response_header(key, value)
      response_headers[key] = value
    end

    def response_headers
      @response_headers ||= {"Content-Type" => (req.json? ? "application/json" : "text/html")}
    end

    def response
      @response ||= Rack::Response.new
    end

    def redirect_to(url)
      raise RedirectError.new(url)
    end

    def cookies
      req.cookies.with_indifferent_access
    end

    def current_user
      begin
        decoded_token = (JWT.decode cookies['access_token'].split(' ').last, App.hmac_secret)[0]
        @current_user = AppUser.first(id: decoded_token["id"])
      rescue StandardError
        nil
      end
    end

  end
end

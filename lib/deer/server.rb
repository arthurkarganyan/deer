module Deer
  class Server
    attr_reader :req

    def initialize(env)
      @req = Request.new(env)
    end

    def self.call(env)
      self.new(env).()
    end

    def cookies
      req.cookies.with_indifferent_access
    end

    def call
      return HealthCheck.() if req.original_path == '/health'
      App.loader.reload if App.development?

      I18n.locale = req.locale.code if defined?(I18n)
      App.locale = req.locale

      clazz, method_to_call = Router.(req.path)

      unless clazz
        return [404, {"Content-Type" => "text/html"}, ['404 Error']]
      end
      obj = clazz.new(req)
      body = if req.json?
              own_methods = clazz.instance_methods - Controller.instance_methods
              if req.delete?
                method_to_call = :delete
              elsif req.put? && method_to_call == :id && clazz.instance_methods.include?(:update)
                method_to_call = :update
              elsif own_methods.include?(method_to_call) && method_to_call != :index
              elsif req.post?
                method_to_call = :create
              end
              res = obj.send(method_to_call)
              if res.is_a? Hash
                res.deep_transform_keys! { |key| key.to_s.camelize(:lower) }
                res.to_json
              else
                {ok: "ok"}.to_json
              end
            else
              obj.send(method_to_call || :index)
            end

      body.gsub!('##META##', "<title>#{req.title || App.name}</title>")

      obj.response.body = [body]
      obj.response_headers.each do |k, v|
        obj.response.set_header(k, v)
      end
      obj.response.finish # finish writes out the response in the expected format.
    rescue JwtError => err
      obj.response.delete_cookie('access_token', path: '/')
      obj.response.redirect('/sessions/new', 302)
      obj.response.finish # finish writes out the response in the expected format.
    rescue StandardError => err
      return err.to_rack_response if err.respond_to? :to_rack_response
      App.logger.error(err)
      begin
        ApplicationError.create_from_error(err)
      rescue StandardError => save_err
        App.logger.error("Couldn't save ApplicationError: #{save_err}")
      end
      if App.development?
        raise err
      else
        if req.json?
          ValidationError.new(t('Some error happened :(')).to_rack_response
        else
          RedirectError.new('/error').to_rack_response
        end
      end
    end
  end
end

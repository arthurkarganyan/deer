module Deer
  class Request < Rack::Request
    attr_reader :title

    def title=(new_title)
      if self.title
        fail "Title already initialized"
      end

      @title = new_title
    end

    def json?
      accept_header = get_header("HTTP_ACCEPT")
      if accept_header && accept_header['application/json']
        return true
      end
      !!(content_type && content_type['application/json'])
    end

    def locale
      return @locale if @locale
      path
      @locale
    end

    def original_path
      if @original_path
        return @original_path
      end

      path rescue nil
      @original_path
    end

    def path
      return @path if @path

      @original_path = super.dup
      @path = @original_path.dup
      @locale = App.locales.find { |i| @path[/\A\/#{i.code}/] }
      unless @locale
        accept_language.each do |(lang_code, probability)|

          @locale = App.locales.find do |i|
            i.code == :en && lang_code == 'en-us' || i.code.to_s == lang_code
          end
          break if @locale
        end
        unless @locale
          @locale = App.locales.find { |i| i.code == :en }
        end
        raise RedirectError.new("/#{@locale.code}#{fullpath}")
      end

      @path.gsub!(/\A\/#{@locale.code}/, "")
      @path
    end

    def params
      @params ||= super.with_indifferent_access
    end
  end
end

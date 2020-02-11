module Deer
  class Router
    attr_reader :path

    def initialize(path)
      @path = path
      if @path.size > 0
        @path = @path[1..-1]
        @path.gsub!(/\d+/, 'id')
        @path.gsub!('stacks/id/flashcards', 'flashcards')
      end
    end

    def self.call(path)
      self.new(path).()
    end

    def self.exists?(target)
      controller, method_name = call(target)
      controller.instance_methods.include? method_name
    end

    def admin?
      !!@path['admin/']
    end

    def call
      return IndexController if path == ''
      if admin?
        splitted = path.split('/')
        splitted.shift
        controller_name = "Admin::" + (splitted.shift + '_controller').camelize
      else
        splitted = path.split('/')
        controller_name = (splitted.shift + '_controller').camelize
      end

      if App.development?
        controller = Kernel.const_get controller_name
      else
        begin
          controller = Kernel.const_get controller_name
        rescue NameError
          raise RedirectError.new('/not_found')
        end
      end
      method_name = splitted.join('_') == '' ? "index" : splitted.join('_')
      method_name = "edit" if method_name == 'id_edit'
      if controller.instance_methods.include?(:_) && !controller.instance_methods.include?(method_name.to_sym)
        method_name = :_
      end
      [controller, method_name.to_sym]
    end
  end
end

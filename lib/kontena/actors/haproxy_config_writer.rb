module Kontena::Actors
  class HaproxyConfigWriter < Concurrent::Actor::RestartingContext
    include Kontena::Logging

    attr_accessor :config_file

    ##
    # @param [String] config_file
    def initialize(config_file = '/etc/haproxy/haproxy.cfg')
      self.config_file = config_file
      @old_config = ''
    end

    def on_message(msg)
      case msg.action
      when :update
        update_config(msg.value)
      else
        pass
      end
    end

    ##
    # @param [String] config
    def update_config(config)
      if @old_config != config
        #info config
        write_config(config)
        @old_config = config
        parent << Message.new(:update_haproxy)
      end
    end

    ##
    # @param [String] config
    def write_config(config)
      File.write(config_file, config.to_s)
    end
  end
end

module Kontena::Models
  class TcpService

    attr_accessor :name,
                  :upstreams,
                  :balance,
                  :custom_settings,
                  :external_port,
                  :health_check_uri

    def initialize(name)
      @name = name
      @upstreams = []
      @balance = 'leastconn'
      @external_port = nil
      @custom_settings = []
      @health_check_uri = nil
    end

    def custom_settings?
      @custom_settings.size > 0
    end

    def upstreams?
      @upstreams.size > 0
    end

    def health_check?
      !@health_check_uri.nil?
    end
  end
end

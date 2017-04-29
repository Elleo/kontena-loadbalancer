module Kontena::Models
  class TcpService

    attr_accessor :name,
                  :upstreams,
                  :balance,
                  :custom_settings,
                  :external_port

    def initialize(name)
      @name = name
      @upstreams = []
      @balance = 'leastconn'
      @external_port = nil
      @custom_settings = []
    end

    def custom_settings?
      @custom_settings.size > 0
    end

    def upstreams?
      @upstreams.size > 0
    end
  end
end

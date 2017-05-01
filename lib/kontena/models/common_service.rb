module Kontena::Models
  module CommonService

    attr_accessor :name,
                  :upstreams,
                  :balance,
                  :health_check_uri,
                  :custom_settings

    def initialize(name)
      @name = name
      @upstreams = []
      @balance = 'roundrobin'
      @health_check_uri = nil
      @custom_settings = []
    end

    def health_check?
      !@health_check_uri.nil?
    end

    def custom_settings?
      @custom_settings.size > 0
    end

    def upstreams?
      @upstreams.size > 0
    end
  end
end

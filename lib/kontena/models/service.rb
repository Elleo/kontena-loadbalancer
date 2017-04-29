module Kontena::Models
  class Service

    attr_accessor :name,
                  :upstreams,
                  :balance,
                  :virtual_hosts,
                  :virtual_path,
                  :keep_virtual_path,
                  :cookie,
                  :basic_auth_secrets,
                  :health_check_uri,
                  :custom_settings

    def initialize(name)
      @name = name
      @upstreams = []
      @balance = 'roundrobin'
      @virtual_hosts = []
      @virtual_path = nil
      @keep_virtual_path = false
      @cookie = nil
      @basic_auth_secrets = nil
      @health_check_uri = nil
      @custom_settings = []
    end

    def keep_virtual_path?
      @keep_virtual_path.to_s == 'true'
    end

    def virtual_hosts?
      @virtual_hosts.size > 0
    end

    def virtual_path?
      !@virtual_path.to_s.empty?
    end

    def cookie?
      !@cookie.nil?
    end

    def basic_auth?
      !@basic_auth_secrets.nil?
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

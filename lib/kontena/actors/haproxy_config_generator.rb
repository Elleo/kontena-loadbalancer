module Kontena::Actors
  class HaproxyConfigGenerator < Concurrent::Actor::RestartingContext
    include Kontena::Logging

    def initialize
      info "initialized"
    end

    # @param [Message] msg
    def on_message(msg)
      case msg.action
      when :update
        update(msg.value)
      else
        pass
      end
    end

    def update(node)
      root = node.key
      services = []
      tcp_services = []
      node.children.each do |c|
        if c.key == "#{root}/services"
          services = generate_services(c)
        elsif c.key == "#{root}/tcp-services"
          tcp_services = generate_tcp_services(c)
        end
      end

      config = Kontena::Views::Haproxy.render({
        format: :text, services: services, tcp_services: tcp_services
      }).each_line.reject{ |l| l.strip == ''.freeze }.join
      parent << Message.new(:write_config, config)
    end

    def generate_services(node)
      services = []
      node.children.sort_by { |c| c.key }.each do |c|
        service = generate_service(c)
        if service.upstreams.size > 0
          services << service
        end
      end

      services
    end

    def generate_service(node)
      root = node
      service = Kontena::Models::Service.new(node.key.split('/')[-1])
      node.children.each do |c|
        if c.key == "#{root.key}/upstreams"
          service.upstreams = c.children.map { |u|
            Kontena::Models::Upstream.new(u.key.split('/')[-1], u.value)
          }
        elsif c.key == "#{root.key}/balance"
          service.balance = c.value
        elsif c.key == "#{root.key}/virtual_hosts"
          service.virtual_hosts = c.value.split(',').compact
        elsif c.key == "#{root.key}/virtual_path"
          service.virtual_path = c.value unless c.value.empty?
        elsif c.key == "#{root.key}/keep_virtual_path"
          service.keep_virtual_path = c.value
        elsif c.key == "#{root.key}/cookie"
          service.cookie = c.value
        elsif c.key == "#{root.key}/basic_auth_secrets"
          service.basic_auth_secrets = c.value
        elsif c.key == "#{root.key}/health_check_uri"
          service.health_check_uri = c.value
        elsif c.key == "#{root.key}/custom_settings"
          service.custom_settings = c.value.split("\n")
        end
      end

      service
    end

    def generate_tcp_services(node)
      services = []
      node.children.sort_by { |c| c.key }.each do |c|
        service = generate_tcp_service(c)
        if service.upstreams.size > 0 && service.external_port
          services << service
        end
      end

      services
    end

    def generate_tcp_service(node)
      root = node
      service = Kontena::Models::TcpService.new(node.key.split('/')[-1])
      node.children.each do |c|
        if c.key == "#{root.key}/upstreams"
          service.upstreams = c.children.map { |u|
            Kontena::Models::Upstream.new(u.key.split('/')[-1], u.value)
          }
        elsif c.key == "#{root.key}/balance"
          service.balance = c.value
        elsif c.key == "#{root.key}/external_port"
          service.external_port = c.value
        elsif c.key == "#{root.key}/custom_settings"
          service.custom_settings = c.value.split("\n")
        end
      end

      service
    end
  end
end

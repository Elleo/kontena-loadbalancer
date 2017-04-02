module Kontena::Actors
  class LbSupervisor < Concurrent::Actor::RestartingContext
    include Kontena::Logging

    # @param [Message] msg
    def on_message(msg)
      #info "got message: #{msg}"
      type = msg.class

      if msg.is_a?(Concurrent::ImmutableStruct::ActorMessage)
        on_message_object(msg)
      elsif msg.is_a?(Symbol)
        on_message_symbol(msg)
      else
        warn "unknown message type: #{type}"
        pass
      end
    end

    def on_message_object(msg)
      case msg.action
      when :start
        start
      when :generate_config
        generate_config(msg.value)
      when :write_config
        write_config(msg.value)
      when :update_haproxy
        update_haproxy
      else
        pass
      end
    end

    def on_message_symbol(action)
      case action
      when :reset
        info "got reset event"
      else
        info "unhandled message symbol: #{action}"
      end
    end

    # @return [String]
    def etcd_node
      ENV.fetch('ETCD_NODE') { '127.0.0.1' }
    end

    # @return [String]
    def etcd_path
      ENV.fetch('ETCD_PATH')
    end

    def start
      @syslog_server = SyslogServer.spawn!(name: 'syslog_server')
      @syslog_server << Message.new(:start)

      @config_generator = HaproxyConfigGenerator.spawn!(name: 'haproxy_config_generator')
      @config_writer = HaproxyConfigWriter.spawn!(name: 'haproxy_config_writer')
      @spawner = HaproxySpawner.spawn!(name: 'haproxy_spawner')

      @etcd_watcher = EtcdWatcher.spawn!(name: 'etcd_watcher', args: [etcd_node, etcd_path])
      @etcd_watcher << Message.new(:start)
    end

    def generate_config(value)
      @config_generator << Message.new(:update, value)
    end

    def write_config(value)
      @config_writer << Message.new(:update, value)
    end

    def update_haproxy
      @spawner << Message.new(:update)
    end

    def on_event(event)
      case event.class
      when Concurrent::Actor::UnknownMessage
        info "on unknown message event: #{event.reference.inspect}"
      else
        info "on event: #{event}"
      end

    end
  end
end

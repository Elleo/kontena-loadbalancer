require 'concurrent/timer_task'
require 'etcd'

module Kontena::Actors
  class EtcdWatcher < Concurrent::Actor::RestartingContext
    include Kontena::Logging

    attr_reader :client, :path

    def initialize(host, path)
      info "initialized with etcd host=#{host} path=#{path}"
      @host = host
      @path = path
      @read_task = Concurrent::TimerTask.new(execution_interval: 0.5) {
        read_etcd
      }
    end

    def default_executor
      Concurrent.global_io_executor
    end

    # @param [Message] msg
    def on_message(msg)
      case msg.action
      when :start
        start
      else
        pass
      end
    end

    def on_event(event)
      info event
    end

    def start
      @read_task.execute
    end

    def client
      @client ||= Etcd::Client.new(host: @host, port: 2379)
    end

    def read_etcd
      response = client.get(path, recursive: true)
      #Actor[:config_generator].async.update(response)
      self.parent << Message.new(:generate_config, response)
    rescue => exc
      error exc.message
    end

    # @param [Array] children
    # @param [Etcd::Node] node
    def map_values_recursive(children, node)
      if node.directory?
        children[node.key.sub(@path, ''.freeze)] = node.value if node.key
        node.children.map{|c| map_values_recursive(children, c) }
      else
        children[node.key.sub(@path, ''.freeze)] = node.value
      end
    end
  end
end

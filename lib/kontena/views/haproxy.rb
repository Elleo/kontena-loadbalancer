require 'erb'

module Kontena::Views
  class Haproxy
    include Hanami::View

    format :text
    template 'haproxy/index'
  end
end

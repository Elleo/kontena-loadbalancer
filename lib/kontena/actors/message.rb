require 'concurrent/immutable_struct'

module Kontena::Actors
  Message = Concurrent::ImmutableStruct.new('ActorMessage', :action, :value)
end

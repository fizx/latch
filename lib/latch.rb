require "thread"
require "timeout"

class Latch
  class Timeout < ::Timeout::Error; end
  module Mixin
    def latch(count = 1, timeout = nil, &block)
      l = Latch.new(count)
      block.call(l)
      l.await(timeout)
    end
    
    extend self
  end
  
  attr_reader :count
  
  def initialize(count = 1)
    @count = 1
    @mutex = Mutex.new
    @mutex.lock
    @cv = ConditionVariable.new
  end
  
  def decr(n = 1)
    @count -= n
    @cv.broadcast if @count <= 0
  end
  
  def await(timeout = nil)
    @cv.wait(@mutex, timeout)
    raise Latch::Timeout if @count > 0
  end
end
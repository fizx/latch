require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

EPSILON = 0.1

describe "Latch" do
  it "should wait" do
    start = Time.now
    l = Latch.new(1)
    Thread.new do
      sleep EPSILON
      l.decr
    end
    l.await
    (Time.now - start).should > EPSILON
  end
  
  it "should wait for the block" do
    start = Time.now
    Latch::Mixin::latch do |l|
      Thread.new do
        sleep EPSILON
        l.decr
      end
    end
    (Time.now - start).should > EPSILON
  end
  
  it "should timeout" do
    start = Time.now
    Latch::Mixin::latch(1, EPSILON) do |l|
      Thread.new do
        sleep 10
        l.decr
      end
    end
    delta = Time.now - start
    delta.should > EPSILON
    delta.should < 2 * EPSILON
  end
  
end

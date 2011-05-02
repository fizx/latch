require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

EPSILON = 0.1
ITEMS = 1

class CustomError < StandardError; end

describe "Latch" do
  it "should wait" do
    start = Time.now
    l = Latch.new(ITEMS)
    Thread.new do
      sleep EPSILON
      l.decr
    end
    l.await
    (Time.now - start).should > EPSILON
  end
  
  it "should not race creation" do
    start = Time.now
    l = Latch.new(ITEMS)
    Thread.new do
      l.decr
    end
    l.await
    (Time.now - start).should < EPSILON
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
    proc {
      Latch::Mixin::latch(ITEMS, EPSILON) do |l|
        Thread.new do
          sleep 10
          l.decr
        end
      end
    }.should raise_error(Latch::Timeout)
  end
  
  it "should have sugar for catching exceptions" do
    start = Time.now
    proc {
      Latch::Mixin::latch(ITEMS, EPSILON) do |l|
        Thread.new do
          l.try {
            raise CustomError
          }
        end
      end
    }.should raise_error(CustomError)
  end
  
end

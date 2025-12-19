require "../spec_helper"

describe Oxide::EventStream do
  describe Oxide::ArrayEventStream do
    it "emits all values from array" do
      stream = Oxide::ArrayEventStream.new([1, 2, 3, 4, 5])
      
      results = [] of Int32
      stream.each do |value|
        results << value
      end

      results.should eq([1, 2, 3, 4, 5])
    end

    it "returns nil after all values are consumed" do
      stream = Oxide::ArrayEventStream.new([1, 2])
      
      stream.next.should eq(1)
      stream.next.should eq(2)
      stream.next.should be_nil
      stream.next.should be_nil
    end

    it "handles empty arrays" do
      stream = Oxide::ArrayEventStream.new([] of Int32)
      
      stream.next.should be_nil
    end

    it "can be closed safely" do
      stream = Oxide::ArrayEventStream.new([1, 2, 3])
      
      stream.next.should eq(1)
      stream.close
      # Should still work after close for array streams
      stream.next.should eq(2)
    end
  end

  describe Oxide::EmptyEventStream do
    it "immediately returns nil" do
      stream = Oxide::EmptyEventStream(Int32).new
      
      stream.next.should be_nil
      stream.next.should be_nil
    end

    it "each block never executes" do
      stream = Oxide::EmptyEventStream(Int32).new
      
      executed = false
      stream.each do |value|
        executed = true
      end

      executed.should be_false
    end
  end

  describe Oxide::ChannelEventStream do
    it "emits values from channel" do
      channel = Channel(Int32).new
      stream = Oxide::ChannelEventStream.new(channel)

      spawn do
        channel.send(1)
        channel.send(2)
        channel.send(3)
        channel.close
      end

      results = [] of Int32
      stream.each do |value|
        results << value
      end

      results.should eq([1, 2, 3])
    end

    it "returns nil when channel is closed" do
      channel = Channel(Int32).new
      stream = Oxide::ChannelEventStream.new(channel)

      channel.close

      stream.next.should be_nil
    end

    it "blocks until value is available" do
      channel = Channel(String).new
      stream = Oxide::ChannelEventStream.new(channel)

      spawn do
        sleep 10.milliseconds
        channel.send("delayed")
        channel.close
      end

      stream.next.should eq("delayed")
      stream.next.should be_nil
    end

    it "can be closed" do
      channel = Channel(Int32).new
      stream = Oxide::ChannelEventStream.new(channel)

      spawn do
        sleep 5.milliseconds
        unless channel.closed?
          channel.send(1)
        end
      end

      stream.next.should eq(1)
      stream.close
      # After closing, channel should be closed
      channel.closed?.should be_true
    end
  end
end

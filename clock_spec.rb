require 'minitest/autorun'
require 'minitest/spec'
require_relative 'clock'

describe Clock do

  describe "#degree_from_time" do
    it "returns 90 degrees for 3pm" do
      clock = Clock.new
      assert clock.degree_from_time('3:00 PM') == 90
    end

    it "returns 90 degrees for 9am" do
      clock = Clock.new
      assert clock.degree_from_time('9:00 AM') == 90
    end

    it "returns 180 degrees for 6am" do
      clock = Clock.new
      assert clock.degree_from_time('6:00 AM') == 180
    end

    it "raise exception if invalid date string" do
      assert_raises do
        clock = Clock.new
        clock.degree_from_time('abcdd')
      end
    end
  end
end

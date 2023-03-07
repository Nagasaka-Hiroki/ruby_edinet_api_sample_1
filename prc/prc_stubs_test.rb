require 'minitest/autorun'
require 'date'

class StubSample < Minitest::Test
    def test_today_stub
        pp Date.today
        
        Date.stub :today, Date.new(2000,1,1) do
            pp Date.today
        end
    end
end
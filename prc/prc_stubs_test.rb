require 'minitest/autorun'
require 'date'

class StubSample < Minitest::Test
    def test_today_stub
        pp Date.today
        
        Date.stub :today, Date.new(2000,1,1) do
            pp Date.today
        end
    end


    def test_another_stub
        a=[2000,1,1]
        b=[2000,12,1]
        pp Date.new(*a)

        Date.stub :new, Date.new(*b) do
            pp Date.new(*a)
        end
    end
    
end
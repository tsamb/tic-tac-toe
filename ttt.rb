require 'minitest/autorun'

class Board
  def initialize
    @moves = Array.new(3) { Array.new(3) }
  end
end

describe Board do
  describe 'when instantiated' do
    before do
      @board = Board.new
    end

    it 'has an empty 3 x 3 array' do
      @board.instance_variable_get(:@moves).length.must_equal 3
      @board.instance_variable_get(:@moves).flatten.length.must_equal 9
    end
  end
end
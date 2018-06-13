# requires Ruby >=2.3 for the safe navigation operator &.

require 'minitest/autorun'
require 'minitest/pride'

class Board
  attr_reader :moves

  def initialize
    @moves = Array.new(3) { Array.new(3) }
  end

  def place_mark(mark, x, y)
    moves[y][x] = mark
    return self
  end

  def winner
    horizontal_winner || nil
  end

  def horizontal_winner
    moves.reject { |row| row.any? { |mark| mark.nil? } }
      .detect { |row| row.uniq.length == 1 }
      &.first
  end

  def vertical_winner
    
  end

  def diagonal_winner
    
  end
end

describe Board do
  before do
    @board = Board.new
  end

  describe 'when instantiated' do
    it 'has an empty 3 x 3 array' do
      @board.instance_variable_get(:@moves).length.must_equal 3
      @board.instance_variable_get(:@moves).flatten.length.must_equal 9
    end
  end

  describe '#moves' do
    it 'returns the current board state' do
      @board.moves.must_equal @board.instance_variable_get(:@moves)
    end
  end

  describe '#place_mark' do
    it 'inserts the given mark into the given coordinate on the board' do
      @board.place_mark('X', 0,0)
      @board.moves[0][0].must_equal 'X'
    end
  end

  describe '#winner' do
    describe 'when no one has won' do

      it 'returns nil' do
        @board.winner.must_be :nil?
      end
    end

    describe 'when someone has won' do
      before do
        winning_moves = [ ['X','X','X'],
                          ['O',nil,nil],
                          ['O',nil,nil]]
        @board.instance_variable_set(:@moves, winning_moves)
      end

      it 'returns the mark of the winner' do
        @board.winner.must_equal 'X'
      end
    end
  end

  describe '#horizontal_winner' do
    describe 'when no one has won' do

      it 'returns nil' do
        @board.horizontal_winner.must_be :nil?
      end
    end

    describe 'when someone has won' do
      before do
        winning_moves = [ ['X','X','X'],
                          ['O',nil,nil],
                          ['O',nil,nil]]
        @board.instance_variable_set(:@moves, winning_moves)
      end

      it 'returns the mark of the winner' do
        @board.horizontal_winner.must_equal 'X'
      end
    end
  end
end
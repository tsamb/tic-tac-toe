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

  def draw?
    !winner && moves.flatten.none? { |move| move.nil? }
  end

  def winner
    horizontal_winner || vertical_winner || diagonal_winner || nil
  end

  def horizontal_winner
    axis_to_winner(horizontals)
  end

  def vertical_winner
    axis_to_winner(verticals)
  end

  def diagonal_winner
    axis_to_winner(diagonals)
  end

  def horizontals
    moves
  end

  def verticals
    moves.transpose
  end

  def diagonals
    [ (0..moves.length - 1).map { |i| moves[i][i] },
      (0..moves.length - 1).map { |i| moves[i][moves.length - 1 - i] }]
  end

  def axis_to_winner(axis_moves)
    axis_moves.reject { |row| row.any? { |mark| mark.nil? } }
      .detect { |row| row.uniq.length == 1 }
      &.first
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

    describe 'when someone has won horizontally' do
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

    describe 'when someone has won vertically' do
      before do
        winning_moves = [ [nil,'X','O'],
                          [nil,'X','O'],
                          ['X',nil,'O']]
        @board.instance_variable_set(:@moves, winning_moves)
      end

      it 'returns the mark of the winner' do
        @board.winner.must_equal 'O'
      end
    end

    describe 'when someone has won diagonally' do
      before do
        winning_moves = [ [nil,'X','O'],
                          [nil,'O','X'],
                          ['O','X','X']]
        @board.instance_variable_set(:@moves, winning_moves)
      end

      it 'returns the mark of the winner' do
        @board.winner.must_equal 'O'
      end
    end
  end

  describe '#horizontal_winner' do
    describe 'when no one has won' do

      it 'returns nil' do
        @board.horizontal_winner.must_be :nil?
      end
    end

    describe 'when X has won horizontally' do
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

    describe 'when O has won horizontally' do
      before do
        winning_moves = [ [nil,'X','X'],
                          [nil,'X',nil],
                          ['O','O','O']]
        @board.instance_variable_set(:@moves, winning_moves)
      end

      it 'returns the mark of the winner' do
        @board.horizontal_winner.must_equal 'O'
      end
    end
  end

  describe '#vertical_winner' do
    describe 'when no one has won' do

      it 'returns nil' do
        @board.vertical_winner.must_be :nil?
      end
    end

    describe 'when X has won vertically' do
      before do
        winning_moves = [ ['O','X',nil],
                          ['O','X',nil],
                          [nil,'X',nil]]
        @board.instance_variable_set(:@moves, winning_moves)
      end

      it 'returns the mark of the winner' do
        @board.vertical_winner.must_equal 'X'
      end
    end

    describe 'when O has won vertically' do
      before do
        winning_moves = [ [nil,'X','O'],
                          [nil,'X','O'],
                          ['X',nil,'O']]
        @board.instance_variable_set(:@moves, winning_moves)
      end

      it 'returns the mark of the winner' do
        @board.vertical_winner.must_equal 'O'
      end
    end
  end

  describe '#diagonal_winner' do
    describe 'when no one has won' do

      it 'returns nil' do
        @board.diagonal_winner.must_be :nil?
      end
    end

    describe 'when X has won diagonally' do
      before do
        winning_moves = [ ['X','O',nil],
                          ['O','X','O'],
                          [nil,'X','X']]
        @board.instance_variable_set(:@moves, winning_moves)
      end

      it 'returns the mark of the winner' do
        @board.diagonal_winner.must_equal 'X'
      end
    end

    describe 'when O has won diagonally' do
      before do
        winning_moves = [ [nil,'X','O'],
                          [nil,'O','X'],
                          ['O','X','X']]
        @board.instance_variable_set(:@moves, winning_moves)
      end

      it 'returns the mark of the winner' do
        @board.diagonal_winner.must_equal 'O'
      end
    end
  end

  describe '#draw?' do
    describe 'when the board is full with no winner' do
      before do
        draw_moves = [['X','O','O'],
                      ['O','X','X'],
                      ['X','X','O']]
        @board.instance_variable_set(:@moves, draw_moves)
      end

      it 'is a draw' do
        @board.draw?.must_equal true
      end
    end

    describe 'when the board is not full' do
      describe 'and no one has won' do
        before do
          mid_play_moves = [['X','O','O'],
                            [nil,nil,nil],
                            [nil,nil,'X']]
          @board.instance_variable_set(:@moves, mid_play_moves)
        end

        it 'is not a draw' do
          @board.draw?.must_equal false
        end
      end

      describe 'and someone has won' do
        before do
          winning_moves = [ ['X','O',nil],
                            ['O','X','O'],
                            [nil,'X','X']]
          @board.instance_variable_set(:@moves, winning_moves)
        end

        it 'is not a draw' do
          @board.draw?.must_equal false
        end
      end
    end
  end
end
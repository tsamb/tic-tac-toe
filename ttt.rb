# requires Ruby >=2.3 for the safe navigation operator &.

require 'minitest/spec'
require 'minitest/pride'

class Game
  attr_reader :board, :view, :players

  VALID_COORDS = /\A\d+,\d+\z/

  def initialize
    @board = Board.new
    @view = BoardView.new
    @players = [Player.new(name: 'Player 1', mark: 'X', human: true),
                Player.new(name: 'Player 2', mark: 'O', human: true)]
  end

  def run
    view.welcome(board)
    until board.game_over? do
      view.display_turn_instructions(current_player)
      coords = next_move(current_player)
      board.place_mark(current_player.mark, *coords)
      view.print_moves(board)
      players.rotate!
    end
    view.game_over(board)
  end

  def current_player
    players.first
  end

  def next_move(player)
    if player.human?
      get_and_validate_input
    else
      # TODO: implement computer player
    end
  end

  def get_and_validate_input
    raw_input = view.get_user_input

    unless raw_input =~ VALID_COORDS
      until raw_input =~ VALID_COORDS do
        view.clarify_input_format
        raw_input = view.get_user_input
      end
    end
    parsed_input = raw_input.split(',').map(&:to_i)
    return parsed_input if board.open_spot?(*parsed_input)
    view.clarify_input_validity
    return get_and_validate_input
  end
end

class BoardView
  def welcome(board)
    puts 'Tic Tac Toe!'
    puts 'When making a move, choose your spot using the following coordinates.'
    puts 'For example, if you wanted to mark the top right, you would enter: 2,0'
    print_coords(board)
    puts
    print_moves(board)
  end

  def print_moves(board)
    padding = ("┼───" * board.moves.length) + "┼\n"
    puts padding
    puts board.moves.map { |row| row.map { |mark| mark ? "│ #{mark} " : "│   " }.join("") + "│" + "\n" }.join(padding)
    puts padding
  end

  def print_coords(board)
    padding = ("┼───" * board.moves.length) + "┼\n"
    puts padding
    puts board.moves.map.with_index { |row, y| row.map.with_index { |mark, x| "│#{x},#{y}"}.join("") + "│" + "\n" }.join(padding)
    puts padding
  end

  def clarify_input_format
    puts "Input must be in x,y format. E.g. for top left you would enter: 0,0"
  end

  def clarify_input_validity
    puts "Coords need to be a valid open spot on the board."
  end

  def display_turn_instructions(player)
    puts "#{player.name}'s turn#{"(computer)" if player.computer? }. (Playing as #{player.mark})"
  end

  def get_user_input
    gets.chomp
  end

  def game_over(board)
    if board.draw?
      puts "Cat's game! (draw)"
    else
      puts "Winner is #{board.winner}!"
    end
  end
end

class CoordinatesNotEmptyError < StandardError; end

class Board
  attr_reader :moves

  def initialize
    @moves = Array.new(3) { Array.new(3) }
  end

  def open_spot?(x,y)
    y < moves.length && x < moves[y].length && moves[y][x].nil?
  end

  def place_mark(mark, x, y)
    raise CoordinatesNotEmptyError.new("existing mark at these coordinates") if moves[y][x]
    moves[y][x] = mark
    return self
  end

  def game_over?
    !!(draw? || winner)
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

class Player
  attr_reader :name, :mark
  def initialize(args = {})
    @name = args.fetch(:name, "Player")
    @mark = args.fetch(:mark, "X")
    @human = args.fetch(:human, true)
  end

  def human?
    @human
  end

  def computer?
    !human?
  end
end

# Game.new.run

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

  describe 'mark placement' do
    describe '#place_mark' do
      describe 'when given coordinates containing no mark' do
        it 'inserts the given mark into the given coordinate on the board' do
          @board.place_mark('X', 0,0)
          @board.moves[0][0].must_equal 'X'
        end
      end

      describe 'when given coordinates containing an existing mark' do
        before do
          mid_play_moves = [['X','O',nil],
                            [nil,nil,nil],
                            [nil,nil,nil]]
          @board.instance_variable_set(:@moves, mid_play_moves)
        end

        it 'raises an error' do
          ->{ @board.place_mark('X', 0,0) }.must_raise CoordinatesNotEmptyError
        end
      end
    end

    describe '#open_spot?' do
      before do
        mid_play_moves = [['X','O','O'],
                          ['X','O',nil],
                          ['O','X','X']]
        @board.instance_variable_set(:@moves, mid_play_moves)
      end
      describe 'when a mark is in the given coordinates' do
        it 'returns false' do
          @board.open_spot?(0,0).must_equal false
        end
      end

      describe 'when no mark is in the given coordinates' do
        it 'returns true' do
          @board.open_spot?(2,1).must_equal true
        end
      end

      describe 'when the given coordinates are off the board' do
        it 'returns true' do
          @board.open_spot?(3,1).must_equal false
          @board.open_spot?(4,0).must_equal false
        end
      end
    end
  end

  describe 'win logic' do
    describe '#winner' do
      describe 'when no one has won' do

        it 'returns nil' do
          @board.winner.must_be_nil
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

    describe '#axis_to_winner' do
      describe 'when passed the rows of moves from a given axis' do
        describe 'when any given row is full of only one mark' do
          it 'returns that mark' do
            axis_moves = [['O',nil,nil],
                          ['X','X','X'],
                          ['O',nil,nil]]
            @board.axis_to_winner(axis_moves).must_equal 'X'
          end
        end

        describe 'when all rows have multiple marks or are not full' do
          it 'returns nil' do
            axis_moves = [['O',nil,nil],
                          ['X','X','O'],
                          [nil,nil,nil]]
            @board.axis_to_winner(axis_moves).must_be :nil?
          end
        end
      end
    end
  end

  describe 'axis transformation logic' do
    before do
      winning_moves = [ ['X','X','X'],
                        ['O',nil,nil],
                        ['O',nil,nil]]
      @board.instance_variable_set(:@moves, winning_moves)
    end

    describe '#horizontals' do
      it 'returns an array of all the board rows' do
        expected_moves = [['X','X','X'],
                          ['O',nil,nil],
                          ['O',nil,nil]]
        @board.horizontals.must_equal expected_moves
      end
    end

    describe '#verticals' do
      it 'returns an array of all the board columns' do
        expected_moves = [['X','O','O'],
                          ['X',nil,nil],
                          ['X',nil,nil]]
      @board.verticals.must_equal expected_moves
      end
    end

    describe '#diagonals' do
      it 'returns an array of all the board diagonals' do
        expected_moves = [['X',nil,nil],
                          ['X',nil,'O']]
        @board.diagonals.must_equal expected_moves
      end
    end
  end
  describe 'final game states' do
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

    describe '#game_over?' do
      describe 'when someone has won' do
        before do
          winning_moves = [ [nil,'X','O'],
                            [nil,'O','X'],
                            ['O','X','X']]
          @board.instance_variable_set(:@moves, winning_moves)
        end

        it 'is true' do
          @board.game_over?.must_equal true
        end
      end

      describe 'when the game has been drawn' do
        before do
          draw_moves = [['X','O','O'],
                        ['O','X','X'],
                        ['X','X','O']]
          @board.instance_variable_set(:@moves, draw_moves)
        end
        it 'is true' do
          @board.game_over?.must_equal true
        end
      end

      describe 'when no one has won and the game is still going' do
        before do
          mid_play_moves = [['X','O','O'],
                            [nil,nil,nil],
                            [nil,nil,'X']]
          @board.instance_variable_set(:@moves, mid_play_moves)
        end

        it 'is false' do
          @board.game_over?.must_equal false
        end
      end
    end
  end
end

describe Player do
  before do
    @player = Player.new
  end

  describe 'when instantiated' do
    describe 'has accessible attributes' do
      describe '#name' do
        it 'defaults to a non-empty string' do
          @player.name.must_match /.+/
        end
      end

      describe '#mark' do
        it 'defaults to a character from A-Z' do
          @player.instance_variable_get(:@mark).must_match /[A-Z]/
        end
      end

      describe '#human?' do
        it 'defaults to true' do
          @player.human?.must_equal true
        end
      end

      describe '.new' do
        describe 'accepts a hash of arguments' do
          it 'returns a new object with the relevant attributes' do
            Player.new({name: 'Sam', mark: 'O', human: true})
          end
        end
      end
    end
  end

  describe '#computer?' do
    describe 'when player is human' do
      before do
        @player = Player.new(name: 'Sam', mark: 'X', human: true)
      end
      it 'is false' do
        @player.computer?.must_equal false
      end
    end

    describe 'when player is not human' do
      before do
        @player = Player.new(name: 'HAL 9000', mark: 'O', human: false)
      end
      it 'is true' do
        @player.computer?.must_equal true
      end
    end
  end
end

Minitest.run

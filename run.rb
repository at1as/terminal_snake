require 'timeout'

class Node
  attr_accessor :prev, :next, :type

  def initialize(prev_node, next_node, type)
    @prev = prev_node
    @next = next_node
    @type = type
  end
end


class Board
  attr_accessor :direction
  
  SIZE = 10
  CLEAR_TERM = "\e[H\e[2J"

  def initialize
    @data = Array.new(SIZE) do
      Array.new(SIZE) do
        Node.new(nil, nil, :unassigned)
      end
    end
    @direction = :up
    @head = nil

    start_snake
  end

  def coords
    Struct.new(:row, :col)
  end

  def start_snake
    start_x, start_y = 4, 4
    @data[start_x][start_y].type = :snake
    @head = coords.new(4, 4)
    
    place_new_block
  end

  def print_board
    puts CLEAR_TERM
    @data.each do |row|
      row.each do |col|
        if (val = col.type) == :snake
          print "S"
        elsif val == :block
          print "B"
        else
          print "."
        end
      end
      puts ?\n
    end
    puts ?\n
  end

  def next_snake
    if @direction == :up
      next_head = coords.new(@head.row - 1, @head.col)
    elsif @direction == :down
      next_head = coords.new(@head.row + 1, @head.col)
    elsif @direction == :left
      next_head = coords.new(@head.row, @head.col - 1)
    elsif @direction == :right
      next_head = coords.new(@head.row, @head.col + 1)
    end
    
    if next_head.row < 0 || next_head.row > (SIZE - 1)
      puts "You hit the wall, you lose!\n"
      exit
    elsif next_head.col < 0 || next_head.col > (SIZE - 1)
      puts "You hit the side wall, you lose!\n"
      exit
    elsif @data[next_head.row][next_head.col].type == :snake
      puts "You hit yourself, you lose!\n"
      exit
    else
      piece_type = "#{@data[next_head.row][next_head.col].type}".to_sym
      @data[next_head.row][next_head.col].type = :snake
      
      @data[@head.row][@head.col].next = @data[next_head.row][next_head.col]
      @data[next_head.row][next_head.col].prev = @data[@head.row][@head.col]

      @head = next_head
      if piece_type == :block
        place_new_block
      else
        remove_tail
      end
    end
  end

  def remove_tail
    node = @data[@head.row][@head.col]
    parent = nil

    while !node.prev.nil? do
      parent = node
      node = node.prev
    end

    parent.prev = nil
    node.next = nil
    node.type = :unassigned
  end

  def place_new_block
    next_block = @data.flatten.select { |square| square.type == :unassigned }.sample
    next_block.type = :block
  end
end


class Runner
  DIRECTIONS = {:w => :up, :a => :left, :s => :down, :d => :right}

  def self.start
    board = Board.new
    prev_dir = DIRECTIONS.keys.sample
    board.direction = prev_dir

    puts "To play, use 'w', 'a', 's', 'd' keys to select direction and then press Enter after changing directions"
    puts "Press Enter to continue..."
    gets

    loop do
      board.print_board

      puts "Move in which direction? (w/a/s/d)"

      begin
        dir = Timeout::timeout(1) { gets.chomp.to_sym }
      rescue
        dir = prev_dir
      end

      next unless [:up, :down, :left, :right].include? DIRECTIONS[dir]
      prev_dir = dir

      board.direction = DIRECTIONS[dir]
      board.next_snake
    end
  
  end
end

Runner.start


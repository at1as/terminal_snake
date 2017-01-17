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
  DIMENSIONS = 10

  def initialize
    @data = Array.new(DIMENSIONS) do
      Array.new(DIMENSIONS) do
        Node.new(nil, nil, :unassigned)
      end
    end
    @direction = :up
    @head = nil
    @next_block = nil 

    start_snake
  end

  def coords
    Struct.new(:row, :col)
  end

  def start_snake
    start_x, start_y = 4, 4
    @data[start_x][start_y].type = :snake
    @head = coords.new(4, 4)
    
    @next_block = coords.new(3, 5)
    @data[3][5].type = :block
  end

  def print_board
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
    if self.direction == :up
      next_head = coords.new(@head.row - 1, @head.col)
    elsif self.direction == :down
      next_head = coords.new(@head.row + 1, @head.col)
    elsif self.direction == :left
      next_head = coords.new(@head.row, @head.col - 1)
    elsif self.direction == :right
      next_head = coords.new(@head.row, @head.col + 1)
    end
    
    if next_head.row < 0 || next_head.row > (DIMENSIONS - 1)
      puts "you hit the wall, you lose!"
    elsif next_head.col < 0 || next_head.col > (DIMENSIONS - 1)
      puts "you hit the side wall, you lose!"
    elsif @data[next_head.row][next_head.col].type == :snake
      puts "you hit yourself, you lose!"
    else
      piece_type = "#{@data[next_head.row][next_head.col].type}".to_sym
      @data[next_head.row][next_head.col].type = :snake
      
      @data[@head.row][@head.col].next = @data[next_head.row][next_head.col]
      @data[next_head.row][next_head.col].prev = @data[@head.row][@head.col]

      @head = next_head
      if piece_type != :block
        self.remove_tail
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
end


class Runner

  def initialize
  end

  def start
    board = Board.new

    loop do
      board.print_board

      puts "Move in which direction?"
      dir = gets.chomp.to_sym

      next unless [:up, :down, :left, :right].include? dir

      board.direction = dir
      board.next_snake
    end
  
  end
end

Runner.new.start


class Life
  attr_reader :board
  attr_accessor :cycles

  BOARD_SIZE = 38
  TICKS_PER_SECOND = 10

  def initialize
    @board = Array.new(BOARD_SIZE) { Array.new(BOARD_SIZE) { Cell.new } }
    @cycles = 0
    @life_count = 0
  end

  def life_cycle
    clear_screen
    display_while_running
    board.each_with_index do |row, row_i|
      row.each_with_index do |cell, col_i|
        neighbors = num_of_neighbors(row_i, col_i, cell)
        case neighbors
        when 0..1
          cell.next_status = :dead
        when 2
          cell.next_status = cell.alive? ? :alive : :dead
        when 3
          cell.next_status = :alive
        when 4..8
          cell.next_status = :dead
        end
      end
    end
    update_all_cells
    self.cycles += 1
  end

  def life_count
    board.flatten.count { |cell| cell.alive? }
  end

  def num_of_neighbors(row_i, col_i, cell)
    row_range = get_index_range(row_i)
    col_range = get_index_range(col_i)
    neighbors = board[row_range].map { |row| row[col_range] }.flatten - [cell]
    neighbors.count { |cell| cell.alive? }
  end

  def get_index_range(index)
    lower = index > 0 ? index - 1 : 0
    upper = index == BOARD_SIZE - 1 ? index : index + 1
    (lower..upper)
  end

  def update_all_cells
    board.each { |row| row.each { |cell| cell.update_status }}
  end

  def display_while_running
    puts "Life cycles: #{cycles} || Life count: #{life_count}"
    puts self
    sleep 1.0 / TICKS_PER_SECOND
  end

  def clear_screen
    print "\e[2J"
    print "\e[H"
  end

  def to_s
    board_string = "__" * BOARD_SIZE + "__\n"
    board_string << board.map { |row| "|#{row.map { |cell| "#{cell}" }.join("")}|\n" }.join("")
    board_string << "¯¯" * BOARD_SIZE + "¯¯\n"
  end
end

class Cell
  CHANCE_OF_LIFE = 25

  attr_accessor :status, :next_status

  def initialize(args = {})
    @status = args[:status] || random_status
    @next_status = nil
  end

  def random_status
    roll = rand(100)
    roll < CHANCE_OF_LIFE ? :alive : :dead
  end

  def update_status
    self.status = next_status
    self.next_status = nil
    self
  end

  def alive?
    status == :alive
  end

  def dead?
    status == :dead
  end

  def to_s
    status == :alive ? "██" : "  "
  end
end

game = Life.new
while true
  game.life_cycle
end

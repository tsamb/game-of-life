require_relative 'cell'

class Life
  BOARD_SIZE = 38
  TICKS_PER_SECOND = 10

  def initialize
    @board = Array.new(BOARD_SIZE) { Array.new(BOARD_SIZE) { Cell.new } }
    @cycles = 0
    @life_count = 0
  end

  def life_cycle
    display_while_running
    each_cell_with_index do |row, row_i, cell, col_i|
      case num_of_neighbors(row_i, col_i, cell)
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
    update_all_cells
    self.cycles += 1
  end

  protected

  attr_accessor :cycles

  private

  attr_reader :board

  BOARD_TOP = "__" * BOARD_SIZE + "__\n"
  BOARD_BOTTOM = "¯¯" * BOARD_SIZE + "¯¯\n"

  def each_cell_with_index
    board.each_with_index do |row, row_i|
      row.each_with_index do |cell, col_i|
        yield(row, row_i, cell, col_i)
      end
    end
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
    BOARD_TOP +
    board.map { |row| "|#{row.map { |cell| "#{cell}" }.join("")}|\n" }.join("") +
    BOARD_BOTTOM
  end
end

game = Life.new
while true
  game.life_cycle
end

require 'set'

class Life
  def next_gen(live_cells)
    live_cell_evolution = live_cells.reduce(Set.new) do |set, cell|
      case neighbor_count(cell, live_cells)
      when 0..1
        set
      when 2..3
        set.add cell
      when 4..8
        set
      end
    end
    dead_neighbor_set(live_cells).reduce(live_cell_evolution) do |set, cell|
      case neighbor_count(cell, live_cells)
      when 0..2
        set
      when 3
        set.add cell
      when 4..8
        set
      end
    end
  end

  private

  def neighboring_coords(coords)
    relative_neighbors = [-1,0,1].product([-1,0,1]) - [[0,0]]
    Set.new(relative_neighbors.map do |neigbor_coords|
      neigbor_coords.zip(coords).map(&:sum)
    end)
  end

  def dead_neighbor_set(live_cells)
    live_cells.reduce(Set.new) do |dead_set, live_cell|
      dead_set.merge(neighboring_coords(live_cell) - live_cells)
    end
  end

  def neighbor_count(coords, live_cells)
    neighboring_coords(coords).intersection(live_cells).size
  end
end

module LifeRunner
  def self.run(ascii = nil)
    life = Life.new
    state = default_state
    state = AsciiConverter.create_set(ascii) if ascii
    cycle = 0
    loop do
      print "\e[2J"
      print "\e[H"
      StdoutRenderer.render(state)
      puts "Generation #{cycle += 1}"
      puts "#{state.size} live cells"
      sleep 1.0/10
      state = life.next_gen(state)
    end
  end

  def self.default_state
    chance_of_life = 0.5
    range = 0...30
    Set.new.tap do |live_cell_set|
      range.each { |x| range.each { |y| live_cell_set.add([x,y]) if rand < chance_of_life  } }
    end
  end

  module AsciiConverter
    ASCII_LIVE_CELL_CHAR = "x"

    def self.create_set(ascii)
      Set.new.tap do |live_cell_set|
        ascii
          .split("\n")
          .map { |row| row.split("") }
          .each_with_index do |row, y|
            row.each_with_index do |cell, x|
              live_cell_set.add([y,x]) if cell == ASCII_LIVE_CELL_CHAR
            end
          end
      end
    end
  end

  module StdoutRenderer
    VIEWPORT_SIZE = 30
    STDOUT_CELL_ICON = "█"

    def self.render(live_cells)
      board = Array.new(VIEWPORT_SIZE) { Array.new(VIEWPORT_SIZE) { "." } }
      live_cells.each do |y, x|
        next if y >= VIEWPORT_SIZE || x >= VIEWPORT_SIZE || y < 0 || x < 0
        board[y][x] = STDOUT_CELL_ICON
      end
      "__" * VIEWPORT_SIZE + "_\n" +
      board.map! { |row| "|#{row.map { |cell| "#{cell}" }.join(" ")}|\n" }.join("") +
      "¯¯" * VIEWPORT_SIZE + "¯\n"
      puts board
    end
  end
end

if ARGV[0] == "--display" || ARGV[0] == "-d"
  file = File.read(ARGV[1]) if ARGV[1]
  LifeRunner.run(file)
end

puts "Tests"
puts "-----"

still_life_ascii = <<~EOS
.....
.xx..
.xx..
.....
EOS
still_life = Life.new
still_life_gen0_cells = LifeRunner::AsciiConverter.create_set(still_life_ascii)

glider_life_ascii = <<~EOS
.x...
..x..
xxx..
.....
EOS
glider_life = Life.new
glider_life_gen0_cells = LifeRunner::AsciiConverter.create_set(glider_life_ascii)

puts "#next_gen returns a new set based on the rules"
puts still_life.next_gen(still_life_gen0_cells) == Set.new([[1,1],[1,2],[2,1],[2,2]])
puts glider_life.next_gen(glider_life_gen0_cells) == Set.new([[1, 2], [2, 1], [2, 2], [1, 0], [3, 1]])
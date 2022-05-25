require 'set'

class Life
  def next_gen(live_cells)
    live_cell_evolution(live_cells) + dead_cell_evolution(live_cells)
  end

  private

  def live_cell_evolution(live_cells)
    evolve(live_cells_with_neighbor_counts(live_cells), 2..3)
  end

  def dead_cell_evolution(live_cells)
    evolve(dead_cells_with_neighbor_counts(dead_neighbor_set(live_cells), live_cells), 3..3)
  end

  def evolve(cells_with_neighbors, alive_within_range)
    cells_with_neighbors.reduce(Set.new) do |set, cell|
      case cell[:neighbor_count]
      when 0..alive_within_range.first-1
        set
      when alive_within_range
        set.add cell[:coords]
      when alive_within_range.last+1..8
        set
      end
    end
  end

  def live_cells_with_neighbor_counts(live_cells)
    live_cells.map { |cell| {coords: cell, neighbor_count: neighbor_count(cell, live_cells)} }
  end

  def dead_cells_with_neighbor_counts(dead_cells, live_cells)
    dead_cells.map { |cell| {coords: cell, neighbor_count: neighbor_count(cell, live_cells)} }
  end

  def neighboring_coords(coords)
    relative_neighbors = [-1,0,1].product([-1,0,1]) - [[0,0]]
    Set.new(relative_neighbors.map do |neighbor_coords|
      neighbor_coords.zip(coords).map(&:sum)
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
    puts "Initial state ="
    p state.to_a
    cycle = 0
    loop do
      print "\e[2J"
      print "\e[H"
      StdoutRenderer.render(state)
      puts "Generation #{cycle += 1}"
      puts "#{state.size} live cells"
      puts "Min x = #{state.min_by { |y,x| x }}, y = #{state.min_by { |y,x| y }} | Max x = #{state.max_by { |y,x| x }}, y = #{state.max_by { |y,x| y }}"
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
      board.map! { |row| "#{row.map { |cell| "#{cell}" }.join(" ")}\n" }.join("") +
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
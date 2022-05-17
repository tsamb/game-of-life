require 'set'

class Life
  def initialize(state)
    @live_cells = Set.new
    state
      .split("\n")
      .map { |row| row.split("") }
      .each_with_index do |row, y|
        row.each_with_index do |cell, x|
          @live_cells.add([y,x]) if cell == "x"
        end
      end
  end

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

  def evolve
    @live_cells = next_gen(@live_cells)
  end

  VIEWPORT_SIZE = 30
  CELL_ICON = "█"

  def to_s
    board = Array.new(VIEWPORT_SIZE) { Array.new(VIEWPORT_SIZE) { "." } }
    @live_cells.each do |y, x|
      next if y >= VIEWPORT_SIZE || x >= VIEWPORT_SIZE || y < 0 || x < 0
      board[y][x] = CELL_ICON
    end
    "__" * VIEWPORT_SIZE + "_\n" +
    board.map { |row| "|#{row.map { |cell| "#{cell}" }.join(" ")}|\n" }.join("") +
    "¯¯" * VIEWPORT_SIZE + "¯\n"
  end
end

initial_state_glider = <<~EOS
.x...
..x..
xxx..
.....
EOS

glider_life = Life.new(initial_state_glider)

if ARGV[0] == "-display"
  loop do
    print "\e[2J"
    print "\e[H"
    puts glider_life
    sleep 1.0/10
    glider_life.evolve
  end
end

p "Tests"
p "-----"

still_life = <<~EOS
.....
.xx..
.xx..
.....
EOS

life = Life.new(still_life)
live_cells = life.instance_variable_get(:@live_cells)

p "#initialize converts x chars in a string input into a set of coordinate pairs"
p life.instance_variable_get(:@live_cells) == Set.new([[1,1],[1,2],[2,1],[2,2]])

p "#neighboring_coords takes a coordinate pair and returns all neighboring coordinates"
p life.neighboring_coords([0,0]) == Set.new([[-1, -1], [-1, 0], [-1, 1], [0, -1], [0, 1], [1, -1], [1, 0], [1, 1]])
p life.neighboring_coords([5,5]) == Set.new([[4, 4], [4, 5], [4, 6], [5, 4], [5, 6], [6, 4], [6, 5], [6, 6]])

p "#dead_neighbor_set takes a set of coords and returns all the neighbors that don't belong in that set"
p life.dead_neighbor_set(live_cells) == Set.new([[0, 0], [0, 1], [0, 2], [1, 0], [2, 0], [0, 3], [1, 3], [2, 3], [3, 0], [3, 1], [3, 2], [3, 3]])

p "#neighbor_count counts a coordinate pair's live neighbors"
p life.neighbor_count([1,1], live_cells) == 3
p life.neighbor_count([0,0], live_cells) == 1
p life.neighbor_count([4,4], live_cells) == 0

p "#next_gen returns a new set based on the rules"
p life.next_gen(live_cells) == Set.new([[1,1],[1,2],[2,1],[2,2]])
p glider_life.next_gen(glider_life.instance_variable_get(:@live_cells)) == Set.new([[1, 2], [2, 1], [2, 2], [1, 0], [3, 1]])
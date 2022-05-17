require 'set'
require 'pry'

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
    binding.pry
  end

  def neighbors(coords)
    relative_neighbors = [-1,0,1].product([-1,0,1]) - [[0,0]]
    Set.new(relative_neighbors.map do |neigbor_coords|
      neigbor_coords.zip(coords).map(&:sum)
    end)
  end

  def dead_neighbor_set(live_cells)
    live_cells.reduce(Set.new) do |dead_set, live_cell|
      dead_set.merge(neighbors(live_cell) - live_cells)
    end
  end
end

# initial_state = <<~EOS
# .x...
# ..x..
# xxx..
# .....
# EOS

initial_state = <<~EOS
.....
.xx..
.xx..
.....
EOS

life = Life.new(initial_state)

p "Tests"
p "-----"
p "#neighbors takes a coordinate pair and returns the neighboring coordinates"
p life.neighbors([0,0]) == Set.new([[-1, -1], [-1, 0], [-1, 1], [0, -1], [0, 1], [1, -1], [1, 0], [1, 1]])
p life.neighbors([5,5]) == Set.new([[4, 4], [4, 5], [4, 6], [5, 4], [5, 6], [6, 4], [6, 5], [6, 6]])

p "#dead_neighbor_set takes a set of coords and returns all the neighbors that don't belong in that set"
p life.dead_neighbor_set(life.instance_variable_get(:@live_cells)) == Set.new([[0, 0], [0, 1], [0, 2], [1, 0], [2, 0], [0, 3], [1, 3], [2, 3], [3, 0], [3, 1], [3, 2], [3, 3]])
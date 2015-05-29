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

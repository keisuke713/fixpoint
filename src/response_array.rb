class ResponseArray
  def initialize(capacity)
    @response = []
    @time = []
    @capacity = capacity
    @sum = 0
  end

  def push(response, time)
    if capacity_is_over?
      res = @response.shift
      @sum -= res
      @time.shift
    end
    @response.push(response)
    @time.push(time)
    @sum += response
  end

  def average
    return -1 if @response.empty? || !is_full?
    @sum / @response.size
  end

  def is_full?
    full(@response)
  end

  def start
    @time[0]
  end

  def empty?
    @response.empty?
  end

  private

  def capacity_is_over?
    @response.size >= @capacity
  end

  def full(array)
    array.size >= @capacity
  end
end
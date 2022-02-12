class ResponseArray
  def initialize(capacity)
    @response = []
    @capacity = capacity
    @sum = 0
  end

  def push(response)
    if capacity_is_over?
      res = @response.shift
      @sum -= res
    end
    @response.push(response)
  end

  def response_average
    return -1 if @response.size.zero? || @response.size < @capacity
    @sum / @response
  end

  def is_max?
    @response.size == @capacity
  end

  def capacity_is_over?
    @response.size >= @capacity
  end
end
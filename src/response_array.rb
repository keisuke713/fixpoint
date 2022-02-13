class ResponseArray
  def initialize(capacity)
    @responses = []
    @times = []
    @capacity = capacity
    @sum = 0
  end

  def push(response, time)
    # 指定されていた容量を超えていたら先頭から削除しないといけないため
    if capacity_is_over?
      res = responses.shift.to_i
      @sum -= res
      times.shift
    end
    responses.push(response)
    times.push(time)
    @sum += response
  end

  def average
    return -1 if responses.empty? || !is_full?
    sum / responses.size
  end

  def is_full?
    full(responses)
  end

  def first_time
    times[0]
  end

  def empty?
    responses.empty?
  end

  private

  def capacity_is_over?
    responses.size >= capacity
  end

  def full(array)
    array.size >= capacity
  end

  private

  def responses
    @responses
  end

  def times
    @times
  end

  def capacity
    @capacity
  end

  def sum
    @sum
  end
end
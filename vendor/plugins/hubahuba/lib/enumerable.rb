module Enumerable
  def map_with_index
    result = []
    each_with_index do |e, i|
      result << yield(e, i)
    end
    result
  end
end

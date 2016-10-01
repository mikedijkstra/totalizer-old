module Totalizer
  module Errors
    class InvalidData < StandardError
    end

    class InvalidModel < InvalidData
    end

    class InvalidDate < InvalidData
    end

    class InvalidDuration < InvalidData
    end
  end
end

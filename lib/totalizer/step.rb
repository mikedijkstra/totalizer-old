module Totalizer
  class Step
    def initialize params
      @params = params
    end

    def change
      @params[:change]
    end

    def change_label
      "#{(change * 100).round(0)}%"
    end

    def ids
      @params[:ids]
    end

    def title
      @params[:title]
    end

    def value
      @params[:value]
    end
  end
end

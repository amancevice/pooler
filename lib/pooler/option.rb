module Pooler
  class Option < ActiveRecord::Base
    belongs_to :category
    has_many   :picks

    default_scope     -> { order(points: :desc).order :name }
    scope :correct,   -> { where id:select{|x| x.correct?   }.collect(&:id) }
    scope :incorrect, -> { where id:select{|x| x.incorrect? }.collect(&:id) }

    def points
      read_attribute(:points) || category.points
    end

    def correct!
      update! correct:true
      picks.collect &:correct!
    end

    def incorrect!
      update! correct:false
      picks.collect &:incorrect!
    end

    def reset!
      update! correct:nil
      picks.collect &:reset!
    end

    def correct?
      correct == true || picks.correct.any?
    end

    def incorrect?
      correct == false || picks.incorrect.any?
    end

    def interpret value
      value.to_s
    end

    def display value
      interpret value
    end
  end

  class DateOption < Option
    def interpret value
      value.to_date
    end

    def display value
      super(value).strftime '%B %-d, %Y'
    end
  end

  class DateTimeOption < Option
    def interpret value
      value.to_datetime
    end

    def display value
      super(value).strftime '%B %-d, %Y %l:%M%P'
    end
  end

  class TimeOption < Option
    # Minutes past midnight
    def interpret value
      value.to_i
    end

    def display value
      (Date.today.to_datetime + super(value)).strftime '%l:%M%P'
    end
  end
end

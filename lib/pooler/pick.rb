module Pooler
  class Pick < ActiveRecord::Base
    belongs_to :user
    belongs_to :category
    belongs_to :option

    before_create :set_pick

    default_scope     -> { joins(:category).order('categories.index').order(:pick) }
    scope :correct,   -> { where correct:true    }
    scope :incorrect, -> { where correct:false   }
    scope :decided,   -> { where.not correct:nil }
    scope :undecided, -> { where correct:nil     }

    def set_pick
      option ||= category.options.first
      pick   ||= option.name
    end

    def correct!
      update! correct:true
    end

    def incorrect!
      update! correct:false
    end

    def reset!
      update! correct:nil
    end

    def correct?
      correct == true
    end

    def incorrect?
      correct == false
    end

    def pick
      # TODO begin/rescue here?
      option.interpret read_attribute(:pick)
    end

    def to_s
      option.display read_attribute(:pick)
    end

    def points type=:actual||:potential
      points = read_attribute(:points) || option.points
      type == :actual && incorrect? ? (penalty||0) : points + (bonus||0)
    end
  end
end

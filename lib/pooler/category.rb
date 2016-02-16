module Pooler
  class Category < ActiveRecord::Base
    has_many :options
    has_many :picks

    before_create :add_index

    default_scope -> { order :index }

    def add_index
      self.index ||= (Category.last&.index||-1) + 1
    end

    def next
      Category.where('index > ?', index).first
    end
  end
end

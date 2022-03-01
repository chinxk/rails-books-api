# frozen_string_literal: true

class Book < ApplicationRecord
  validates :isbn, presence: true, length: { maximum: 13 }, uniqueness: true
end

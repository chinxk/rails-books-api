# frozen_string_literal: true

class Book < ApplicationRecord
  validates :isbn, presence: true, length: { maximum: 13 }, uniqueness: true

  has_many :user_books
  has_many :users, through: :user_books
end

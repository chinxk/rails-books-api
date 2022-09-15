# frozen_string_literal: true

class UserBook < ApplicationRecord
  belongs_to :user
  belongs_to :book

  default_scope { order(updated_at: :desc) }
end

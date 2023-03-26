class Article < ApplicationRecord
  validates :title, presence: true, length: { maximum: 50 }
  validates :content, presence: true

  scope :latest, -> {order(created_at: :desc)}
  scope :old, -> {order(created_at: :asc)}
  scope :active, -> {where(deleted_at: nil)}
end

class Product < ApplicationRecord
  mount_uploader :image, ImageUploader
  belongs_to :category
  has_many :reviews
  has_many :photos
  accepts_nested_attributes_for :photos
end

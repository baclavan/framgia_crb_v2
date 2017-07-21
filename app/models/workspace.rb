class Workspace < ApplicationRecord
  mount_uploader :logo, ImageUploader

  belongs_to :organization
  has_many :calendars

  delegate :name, to: :organization, prefix: true, allow_nil: true
end

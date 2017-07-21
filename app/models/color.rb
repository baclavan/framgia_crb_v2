class Color < ApplicationRecord
  include ColorAdmin

  has_many :calendars
  has_many :user_calendars
end

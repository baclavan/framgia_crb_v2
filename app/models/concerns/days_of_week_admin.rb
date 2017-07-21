module DaysOfWeekAdmin
  extend ActiveSupport::Concern
  included do
    rails_admin do
      edit do
        field :name
      end
    end
  end
end

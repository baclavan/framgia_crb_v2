module ColorAdmin
  extend ActiveSupport::Concern

  included do
    rails_admin do
      edit do
        field :title
        field :color_hex
      end
    end
  end
end

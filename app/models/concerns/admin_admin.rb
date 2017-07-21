module AdminAdmin
  extend ActiveSupport::Concern

  included do
    rails_admin do
      edit do
        field :email
        field :password
        field :password_confirmation
      end
    end
  end
end

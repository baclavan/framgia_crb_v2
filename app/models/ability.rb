class Ability
  include CanCan::Ability

  def initialize user
    user ||= NullUser.new

    if user.nil?
      can :show, Calendar
      return
    end

    can :manage, User, id: user.id
    can [:create, :update], Calendar
    can :destroy, Calendar do |calendar|
      calendar.creator == user
    end
    can :manage, Event do |event|
      user.can_make_changes_and_manage_sharing?(event.calendar) || user.can_make_changes_to_events?(event.calendar)
    end
    can :show, Event
    can :manage, Organization, creator_id: user.id
  end
end

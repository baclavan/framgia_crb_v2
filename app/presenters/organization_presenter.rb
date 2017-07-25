class OrganizationPresenter
  include ActiveModel::Validations

  attr_accessor :organization

  validates :organization, presence: true

  def initialize organization
    @organization = organization
    calendars
  end

  def workspaces
    @workspaces ||= @organization.workspaces
  end

  def members
    @members ||= @organization.accepted_users
  end

  def workspace_calendars
    @calendars.select{|calendar| calendar.workspace_id.present?}.group_by(&:workspace)
  end

  def direct_calendars
    @calendars.select{|calendar| calendar.workspace_id.nil?}
  end

  def activities
    @activities = PublicActivity::Activity.order(created_at: :desc)
                                          .where owner_type: User.name,
                                                 recipient_type: Organization.name,
                                                 recipient_id: @organization.id
    @activities.map{|activity| ActivityPresenter.new activity}
  end

  private

  def calendars
    @calendars ||= Calendar.includes(:workspace).of_org(@organization)
  end
end

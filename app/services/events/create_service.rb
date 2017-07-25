module Events
  class CreateService
    include MakeActivity
    attr_accessor :is_overlap, :event

    def initialize event, params
      @event = event
      @params = params
      modify_repeat_params if @params[:repeat].blank?
    end

    def perform
      return false if is_overlap? && !@event.calendar.is_allow_overlap?
      begin
        ActiveRecord::Base.transaction do
          make_and_assign_attendees
          @event.save!
          if @params[:group_attendee_name].present?
            make_group_attendee
          end
          make_activity @event.owner, @event, :create
        end
      rescue ActiveRecord::RecordInvalid => exception
        Rails.logger.info('----------------------> ERRORS!!!!')
      end
    end

    private

    def modify_repeat_params
      %i(repeat_type repeat_every start_repeat end_repeat).each do |attribute|
        @event[attribute.to_sym] = nil
      end
      @event.repeat_ons_attributes = []
    end

    def make_group_attendee
      group_attendee = GroupAttendee.new name: @params[:group_attendee_name], user_id: @event.owner.id
      group_attendee.attendees = Attendee.where(email: @params[:attendee][:emails])
      group_attendee.save!
    end

    def is_overlap?
      overlap_time_handler = OverlapTimeHandler.new @event
      @is_overlap = overlap_time_handler.valid?
    end

    def attendee_emails
      return [] if @params[:attendee].blank?
      return @params[:attendee][:emails]
    end

    def make_and_assign_attendees
      users = User.where(email: attendee_emails).select(:email, :id)
      attendees = Attendee.where(email: attendee_emails)
      emails = users.map(&:email) + attendees.map(&:email)

      users.each do |user|
        attendees += [Attendee.find_or_initialize_by(user_id: user.id)]
      end

      attendee_emails.each do |email|
        next if emails.include?(email)
        attendees += [Attendee.new(email: email)]
      end
      @event.attendees = attendees.uniq
    end
  end
end

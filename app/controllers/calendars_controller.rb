class CalendarsController < ApplicationController
  skip_before_action :authenticate_user!, only: :index
  load_and_authorize_resource except: :index
  before_action :verify_permission!, only: %i(edit update)
  before_action :load_colors, except: %i(show destroy)
  before_action :load_users, :load_permissions, only: %i(new edit)

  def index
    @organization = Organization.find_by slug: params[:organization_id]
    @calendar_presenter = CalendarPresenter.new context_user, @organization
    @event = Event.new if user_signed_in?
  end

  def create
    @calendar.creator_id = current_user.id

    if @calendar.save
      redirect_to root_path, flash: {success: t("calendar.success_create")}
    else
      load_users
      load_permissions
      flash.now[:alert] = t "calendar.danger_create"
      render :new
    end
  end

  def new
    @calendar.creator = current_user
    @calendar.owner = owner
    @calendar.color = @colors.sample
  end

  def edit
    @user_selected = User.find_by email: params[:email] if params[:email]
  end

  def update
    if @calendar.update_attributes calendar_params
      redirect_to root_path, flash: {success: t("calendar.success_update")}
    else
      render :edit
    end
  end

  def destroy
    if @calendar.destroy
      flash[:success] = t "calendars.deleted"
    else
      flash[:alert] = t "calendars.not_deleted"
    end
    redirect_to root_path
  end

  private

  def calendar_params
    params.require(:calendar).permit Calendar::ATTRIBUTES_PARAMS
  end

  def load_colors
    @colors = Color.all
  end

  def load_users
    @users = User.all
  end

  def load_permissions
    @permissions = Permission.all
  end

  def verify_permission!
    return if context_user.can_make_changes_and_manage_sharing?(@calendar)
    flash[:alert] = t("flash.messages.not_permission")
    redirect_to root_path
  end

  def owner
    if params[:organization_id]
      @organization = Organization.find_by slug: params[:organization_id]
    end

    return current_user if @organization.nil?
    @organization
  end
end

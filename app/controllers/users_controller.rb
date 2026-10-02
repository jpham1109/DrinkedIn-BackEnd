# frozen_string_literal: true

class UsersController < ApplicationController
  wrap_parameters :user,
                  include: %i[full_name username password workplace bartender instagram_account avatar]

  def index
    users = User.includes(:bars, :cocktails, :likes, :followed_users, :following_users, :image_attachment).order(:id)
    render json: users, except: %i[created_at updated_at]
  end

  def show
    user = User.find(params[:id])
    render json: user, except: %i[created_at updated_at]
  end

  # PR 1's skip_forgery_protection only: :signup is removed here (PR 2) —
  # signup now establishes a session, so it must be CSRF-protected. Ships
  # in the same deploy as the frontend's CSRF/credentials transport
  # (ai/auth-migration-plan.md PR 2, "Sequencing correction").
  #
  # The jwt field (PR 2's temporary compatibility with the pre-cutover
  # bearer-JWT frontend) is removed here (PR 5) — the frontend has used
  # session/CSRF auth exclusively since PR 3/4, so there's no remaining
  # consumer of it.
  def signup
    user = User.new(user_params)
    if user.save
      reset_session
      session[:user_id] = user.id
      create_workplace_if_requested(user)
      render_success({ user: UserSerializer.new(user) }, status: :created)
    else
      render_validation_errors(user)
    end
  end

  def me
    render json: current_user
  end

  def update
    updated_params = user_params.except(:avatar)
    current_user.assign_attributes(updated_params)

    if user_params[:avatar].present?
      upload_errors = current_user.image_upload_errors(user_params[:avatar])
      return render json: { errors: upload_errors }, status: :unprocessable_entity if upload_errors.any?

      current_user.attach_image(user_params[:avatar])
    end

    if current_user.save
      ProcessImageVariantJob.perform_later(current_user) if user_params[:avatar].present?
      render json: current_user
    else
      render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    current_user.destroy
    render json: { message: 'User deleted.' }, status: :ok
  end

  private

  def user_params
    params.require(:user).permit(:full_name, :username, :password, :location, :bartender, :avatar)
  end

  # Only ever called from the success branch of #signup (see above) — the
  # previous version of this logic ran unconditionally regardless of
  # whether signup succeeded, which could create an orphaned Bar record
  # on a failed signup. Fixed as part of the PR 2 restructuring
  # (ai/auth-migration-plan.md PR 2, item 2).
  def create_workplace_if_requested(user)
    return unless params[:work_at]

    bar = Bar.find_or_create_by(name: params[:work_at])
    Workplace.create(bar_id: bar.id, bartender_id: user.id)
  end

  # Same reasoning as SessionsController#create — see there for the full
  # comment. current_user is always blank on a signup attempt by
  # definition.
  def prefer_authentication_error_over_csrf?
    return false if action_name == 'signup'

    super
  end
end

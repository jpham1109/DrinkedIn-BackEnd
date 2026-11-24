# frozen_string_literal: true

class UsersController < ApplicationController
  wrap_parameters :user,
                  include: %i[full_name username password workplace bartender instagram_account avatar email]

  # ai/v1-redesign-plan.md's privacy-first-user-discovery workstream
  # (2026-11-23), Step 3 — Kinpour launches as a private-by-default
  # account model: the public user directory (#index) and an individual
  # profile lookup (#show) are no longer anonymous/open endpoints.
  # require_editor (AuthenticatesRequest, unmodified) already returns
  # 401 for an unauthenticated caller and 403 for an authenticated
  # non-editor — #index just adopts that existing behavior as-is.
  before_action :require_editor, only: :index
  before_action :find_user, only: :show
  before_action :require_self_or_editor, only: :show

  def index
    users = User.includes(:bars, :cocktails, :likes, :followed_users, :following_users, :image_attachment).order(:id)
    render json: users, except: %i[created_at updated_at]
  end

  def show
    render json: @user, except: %i[created_at updated_at]
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
    user = User.new(signup_params)
    if user.save
      reset_session
      session[:user_id] = user.id
      create_workplace_if_requested(user)
      render_success({ user: AccountSerializer.new(user) }, status: :created)
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
      # with_follow_identities: same preloaded-reload reasoning as
      # SessionsController#show/#create — avoids N+1 on
      # AccountSerializer's enriched followed_users/following_users.
      render json: User.with_follow_identities.find(current_user.id), serializer: AccountSerializer
    else
      render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    current_user.destroy
    render json: { message: 'User deleted.' }, status: :ok
  end

  private

  # editor is deliberately absent — ai/v1-redesign-plan.md's
  # editorial-authorization workstream (2026-11-18): editorial
  # privileges must never be assignable through public signup or
  # profile updates. Granting editor: true is a separate, documented
  # Rails-console action, never reachable through this params list.
  #
  # email is deliberately absent here too — ai/v1-redesign-plan.md's
  # users.email workstream (2026-11-19): accepted at signup only (see
  # signup_params below), not through this general profile-update path,
  # until a verification-aware change-of-email flow exists. A PATCH /me
  # request that includes an email param has it silently dropped, same
  # as any other unpermitted field.
  def user_params
    params.require(:user).permit(:full_name, :username, :password, :location, :bartender, :avatar)
  end

  # Signup-only — see the comment on user_params above for why this
  # isn't just user_params with email merged in.
  def signup_params
    params.require(:user).permit(:full_name, :username, :password, :location, :bartender, :avatar, :email)
  end

  def find_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_not_found
  end

  # 404, never 403 — same concealment rule already established for
  # draft cocktails (CocktailLookup#require_published_or_editor): a
  # non-owner/non-editor must not be able to distinguish "this account
  # doesn't exist" from "it exists but isn't visible to you." Applies
  # regardless of auth state (an anonymous caller gets this same 404,
  # not a 401 — unlike #index, this isn't a blanket "you must be an
  # editor" gate, it's per-id concealment).
  def require_self_or_editor
    return if current_user&.editor? || current_user&.id == @user.id

    render_not_found
  end

  def render_not_found
    response.headers['Cache-Control'] = 'private, no-store'
    render_error(code: 'not_found', message: 'User not found.', status: :not_found)
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

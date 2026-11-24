# frozen_string_literal: true

class FollowsController < ApplicationController
  before_action :require_login, only: %i[create destroy]
  before_action :find_follow, only: :destroy
  before_action :require_follow_participant, only: :destroy

  # ai/v1-redesign-plan.md's privacy-first-user-discovery workstream
  # (2026-11-23), Step 3 — closes the enumeration gap found auditing
  # this action: a followee must already be a public creator
  # (User.followable, Step 1's single source of truth for this check,
  # reused here rather than redefined) before a Follow can be created
  # at all. A nonexistent followee_id and an existing-but-private one
  # now produce the identical 404 (never a distinguishing error), so
  # guessing ids reveals nothing either way.
  #
  # Also fixes a pre-existing bug this same read surfaced: the previous
  # `Follow.create` never checked success, so a failed creation (this
  # new eligibility rejection, or the already-existing duplicate-follow
  # uniqueness validation) silently rendered the invalid, unsaved
  # record's bare attributes as if it had succeeded.
  def create
    followee = User.followable.find_by(id: params['followee_id'])
    return render_not_found if followee.nil?

    @follow = Follow.new(follower_id: current_user.id, followee_id: followee.id)
    if @follow.save
      render json: @follow
    else
      render_validation_errors(@follow)
    end
  end

  def destroy
    @follow.destroy!
    render json: {}, status: :no_content
  end

  private

  def find_follow
    @follow = Follow.find(params[:id])
  end

  # Either side of a Follow relationship may end it: the follower
  # (unfollow) or the followee (remove follower). An unrelated
  # authenticated user stays forbidden — only destroy touches this, so
  # there's no case where a non-participant should be able to delete it.
  def require_follow_participant
    return if [@follow.follower_id, @follow.followee_id].include?(current_user.id)

    render json: { error: 'Forbidden' }, status: :forbidden
  end

  # Matches the concealment convention already established elsewhere
  # (CocktailLookup#require_published_or_editor, UsersController) — a
  # response that let a caller distinguish "no such account" from
  # "exists but private" would itself be a (smaller) enumeration leak.
  def render_not_found
    response.headers['Cache-Control'] = 'private, no-store'
    render_error(code: 'not_found', message: 'User not found.', status: :not_found)
  end
end

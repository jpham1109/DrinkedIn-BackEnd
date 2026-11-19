# frozen_string_literal: true

class LikesController < ApplicationController
  before_action :require_login, only: %i[create destroy]
  before_action :find_like, only: %i[show destroy]
  before_action :require_like_owner, only: %i[destroy]

  def index
    @likes = Like.order(:id).includes(%i[liked_cocktail liker])
    # ai/v1-redesign-plan.md's publication-lifecycle workstream
    # (2026-11-18) — a like on a draft cocktail must not surface
    # through this public collection for a non-editor. The Like row
    # itself is never touched by publish/unpublish — only this
    # read-time scope changes, so a like survives an unpublish and
    # reappears here if the cocktail is republished.
    @likes = @likes.joins(:liked_cocktail).merge(Cocktail.published) unless current_user&.editor?
    render json: @likes
  end

  def show
    render json: @like
  end

  # Looks up the cocktail first so a non-editor can't like (or confirm
  # the existence of) a draft by directly supplying its id — same
  # concealment rule as CocktailsController#show, never a 403 here
  # either. Editors may like drafts.
  def create
    cocktail = Cocktail.find_by(id: params['liked_cocktail_id'])
    if cocktail.nil? || (!cocktail.published? && !current_user&.editor?)
      return render_error(code: 'not_found', message: 'Cocktail not found.', status: :not_found)
    end

    @like = Like.create(liker_id: current_user.id, liked_cocktail_id: cocktail.id)
    render json: @like
  end

  def destroy
    @like.destroy!
    render json: {}, status: :no_content
  end

  private

  def find_like
    @like = Like.find(params[:id])
  end

  def require_like_owner
    render json: { error: 'Forbidden' }, status: :forbidden unless @like.liker_id == current_user.id
  end
end

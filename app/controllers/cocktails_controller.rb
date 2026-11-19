# frozen_string_literal: true

class CocktailsController < ApplicationController
  include CocktailLookup

  # ai/v1-redesign-plan.md's editorial-authorization workstream
  # (2026-11-18) — replaces the old owner-based require_login +
  # require_cocktail_owner pair. Kinpour's catalog is editor-managed,
  # not self-service: there is no remaining case where an ordinary
  # submitter may create, edit, or delete a cocktail record.
  before_action :require_editor, only: %i[create update destroy publish unpublish]
  before_action :find_cocktail, only: %i[show update destroy publish unpublish]
  # Publication-lifecycle workstream (2026-11-18) — a draft requested by
  # a non-editor gets 404, never 403, so a non-editor can't distinguish
  # "doesn't exist" from "exists but is a draft." Declared after
  # find_cocktail so @cocktail is loaded first.
  before_action :require_published_or_editor, only: %i[show]
  before_action :convert_to_array, only: %i[create update]
  wrap_parameters :cocktail, include: %i[name description execution ingredients category image]

  def index
    cocktails = Cocktail.includes(:category, :submitted_by, :creator_user, image_attachment: :blob)
                        .order(created_at: :desc)
    # Explicit scope, not a default_scope — see Cocktail.published.
    # Authorized editors see drafts too, through this same endpoint.
    cocktails = cocktails.published unless current_user&.editor?
    set_draft_cache_headers if current_user&.editor?
    render_collection(cocktails)
  end

  def show
    set_draft_cache_headers if current_user&.editor?
    render_success(@cocktail)
  end

  # Editor-only, server-generated timestamp — never a client-supplied
  # published_at (see cocktail_params). Idempotent: publishing an
  # already-published cocktail doesn't bump its timestamp. Triggers
  # Cocktail's publish-gated validations (creator attribution + recipe
  # completeness).
  def publish
    @cocktail.published_at ||= Time.current
    if @cocktail.save
      render_success(@cocktail)
    else
      render_validation_errors(@cocktail)
    end
  end

  def unpublish
    @cocktail.published_at = nil
    if @cocktail.save
      render_success(@cocktail)
    else
      render_validation_errors(@cocktail)
    end
  end

  def create
    cocktail = Cocktail.new(cocktail_params.except(:photo))
    cocktail.submitted_by_id = current_user.id
    cocktail.category_id = cocktail_params[:category_id]
    cocktail.ingredients = @ingredients_array

    if cocktail_params[:photo].present?
      upload_errors = cocktail.image_upload_errors(cocktail_params[:photo])
      return render_upload_errors(upload_errors) if upload_errors.any?

      cocktail.attach_image(cocktail_params[:photo])
    end

    if cocktail.save
      ProcessImageVariantJob.perform_later(cocktail) if cocktail_params[:photo].present?
      render_success(cocktail, status: :created)
    else
      render_validation_errors(cocktail)
    end
  end

  def update
    updated_params = cocktail_params.except(:photo)
    updated_params[:ingredients] = @ingredients_array if cocktail_params[:ingredients].present?
    @cocktail.assign_attributes(updated_params)

    if cocktail_params[:photo].present?
      upload_errors = @cocktail.image_upload_errors(cocktail_params[:photo])
      return render_upload_errors(upload_errors) if upload_errors.any?

      @cocktail.attach_image(cocktail_params[:photo])
    end

    if @cocktail.save
      ProcessImageVariantJob.perform_later(@cocktail) if cocktail_params[:photo].present?
      render_success(@cocktail)
    else
      render_validation_errors(@cocktail)
    end
  end

  def destroy
    @cocktail.destroy
    head :no_content
  end

  private

  # submitted_by_id and published_at are deliberately absent — the
  # former is always server-derived from current_user (never
  # client-supplied, never mutable after creation, see #create above);
  # the latter is only ever changed via the dedicated #publish/
  # #unpublish actions, never through this general-purpose update.
  def cocktail_params
    params.require(:cocktail).permit(
      :id, :name, :description, :execution, :ingredients, :category_id, :photo,
      :creator_user_id, :creator_name, :creator_unknown
    )
  end

  def convert_to_array
    @ingredients_array = if cocktail_params[:ingredients].instance_of?(String)
                           cocktail_params[:ingredients].split(',').map(&:strip)
                         else
                           cocktail_params[:ingredients]
                         end
  end

  # Publication-lifecycle workstream (2026-11-18) — any response that
  # could include editor-only (draft) cocktail data must not be cached
  # by an intermediate cache. Applied whenever current_user is an
  # editor, unconditionally — the only condition under which a draft
  # could ever appear in the response, so no need to inspect the actual
  # records returned.
  def set_draft_cache_headers
    response.headers['Cache-Control'] = 'private, no-store'
  end
end

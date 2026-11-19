# frozen_string_literal: true

# Shared by CocktailsController and Cocktails::ImagesController —
# loading a cocktail by id, and the draft-concealment rule that applies
# equally to reading the record itself and reading its image.
module CocktailLookup
  extend ActiveSupport::Concern

  private

  # Round-5 review check: a genuinely nonexistent id and a concealed
  # draft must be indistinguishable to a non-editor — same status, same
  # JSON envelope, same Cache-Control. Before this rescue, a nonexistent
  # id raised ActiveRecord::RecordNotFound unhandled (confirmed live,
  # not assumed) instead of reaching require_published_or_editor's
  # render at all, which would have been a real, visible difference
  # (an unhandled-exception response, not a 404 envelope). Both paths
  # now funnel through the same render_not_found.
  def find_cocktail
    @cocktail = Cocktail.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_not_found
  end

  # ai/v1-redesign-plan.md's publication-lifecycle workstream
  # (2026-11-18) — 404, never 403: a non-editor must not be able to
  # distinguish "doesn't exist" from "exists but is a draft."
  def require_published_or_editor
    return if @cocktail.published? || current_user&.editor?

    render_not_found
  end

  def render_not_found
    response.headers['Cache-Control'] = 'private, no-store'
    render_error(code: 'not_found', message: 'Cocktail not found.', status: :not_found)
  end
end

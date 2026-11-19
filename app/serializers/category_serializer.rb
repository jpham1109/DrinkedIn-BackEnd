# frozen_string_literal: true

class CategorySerializer < ActiveModel::Serializer
  attributes :id, :name, :definition
  has_many :cocktails
  # override the cocktails method to only return the ids of the cocktails
  class CocktailSerializer < ActiveModel::Serializer
    attributes :id
  end

  # ai/v1-redesign-plan.md's publication-lifecycle workstream
  # (2026-11-18) — even an id-only nested list must not reveal a draft
  # cocktail's existence to a non-editor. `current_user` is available
  # here for free: CategoriesController renders via plain `render
  # json:`, which AMS's controller integration auto-scopes to
  # current_user by default. `respond_to?(:current_user)` guards the
  # rare case this serializer is ever manually instantiated without a
  # scope (see UserSerializer#editor_viewing? for a real example of
  # that happening elsewhere) — fails closed, not raising.
  def cocktails
    editor_viewing? ? object.cocktails : object.cocktails.published
  end

  private

  def editor_viewing?
    respond_to?(:current_user) && current_user&.editor?
  end
end

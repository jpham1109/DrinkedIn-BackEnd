# frozen_string_literal: true

class CategoriesController < ApplicationController
  def index
    @categories = Category.order(:id).includes(:cocktails)
    render json: @categories
  end

  def show
    @category = Category.find(params[:id])
    render json: @category
  end
end

class BarsController < ApplicationController
    def index
        @bars = Bar.all
        render json: @bars, except: [:created_at, :updated_at]
    end

    def show
        @bar = Bar.find(params[:id])
        render json: @bar, except: [:created_at, :updated_at]
    end

    
end

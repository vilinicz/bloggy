module Api
  class OverviewController < ApplicationController
    def index
      render json: OverviewQuery.new.call
    end
  end
end

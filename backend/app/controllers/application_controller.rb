class ApplicationController < ActionController::API
  include Pagy::Method

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :render_record_invalid

  private

  def render_not_found
    render json: { error: "Not found" }, status: :not_found
  end

  def render_record_invalid(exception)
    render json: { errors: exception.record.errors.to_hash },
           status: :unprocessable_entity
  end
end

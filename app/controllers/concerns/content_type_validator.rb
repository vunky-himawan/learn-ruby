module ContentTypeValidator
  extend ActiveSupport::Concern

  private

  def validate_content_type
    unless request.content_type == "application/json"
      render json: { error: "Content-Type must be application/json" },
             status: :unsupported_media_type
    end
  end
end

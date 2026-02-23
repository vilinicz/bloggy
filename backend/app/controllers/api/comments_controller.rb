module Api
  class CommentsController < ApplicationController
    before_action :set_article

    def index
      pagy, comments = pagy(:keyset, comments_scope)

      render json: {
        items: comments,
        next_cursor: pagy.next
      }
    end

    def create
      comment = @article.comments.create!(comment_params)
      render json: comment, status: :created
    end

    private

    def set_article
      @article = Article.find(params[:article_id])
    end

    def comment_params
      params.require(:comment).permit(:body, :author_name)
    end

    def comments_scope
      @article
        .comments
        .select(:id, :body, :author_name, :article_id, :created_at)
        .order(created_at: :desc, id: :desc)
    end
  end
end

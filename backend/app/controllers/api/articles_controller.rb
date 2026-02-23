module Api
  class ArticlesController < ApplicationController
    def index
      pagy, articles = pagy(:keyset, articles_scope)

      render json: {
        items: articles,
        next_cursor: pagy.next
      }
    end

    def show
      render json: Article.find(params[:id])
    end

    def create
      article = Article.create!(article_params)
      render json: article, status: :created
    end

    private

    def article_params
      params.require(:article).permit(:title, :body, :author_name)
    end

    def articles_scope
      Article
        .select(:id, :title, :author_name, :created_at, :comments_count)
        .order(created_at: :desc, id: :desc)
    end
  end
end

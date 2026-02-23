require "rails_helper"

RSpec.describe "Comments API", type: :request do
  let!(:article) do
    Article.create!(
      title: "Article title",
      body: "Article body",
      author_name: "Author"
    )
  end

  describe "GET /api/articles/:article_id/comments" do
    it "returns comments for the article with required fields" do
      older = article.comments.create!(body: "Older comment", author_name: "Alice")
      newer = article.comments.create!(body: "Newer comment", author_name: "Bob")

      get "/api/articles/#{article.id}/comments", params: { limit: 30 }

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json["items"].map { |item| item["id"] }).to eq([newer.id, older.id])
      expect(json["items"].first.keys).to include(
        "id",
        "body",
        "author_name",
        "created_at",
        "article_id"
      )
    end

    it "supports keyset cursor pagination" do
      first = article.comments.create!(body: "Comment 1", author_name: "A")
      second = article.comments.create!(body: "Comment 2", author_name: "B")
      third = article.comments.create!(body: "Comment 3", author_name: "C")

      get "/api/articles/#{article.id}/comments", params: { limit: 2 }
      expect(response).to have_http_status(:ok)
      first_page = JSON.parse(response.body)

      expect(first_page["items"].map { |item| item["id"] }).to eq([third.id, second.id])
      expect(first_page["next_cursor"]).to be_a(String)

      get "/api/articles/#{article.id}/comments", params: {
        limit: 2,
        cursor: first_page["next_cursor"]
      }

      expect(response).to have_http_status(:ok)
      second_page = JSON.parse(response.body)
      expect(second_page["items"].map { |item| item["id"] }).to eq([first.id])
      expect(second_page["next_cursor"]).to be_nil
    end
  end

  describe "POST /api/articles/:article_id/comments" do
    it "creates a comment and updates counter cache" do
      expect do
        post "/api/articles/#{article.id}/comments",
             params: {
               body: "Great post",
               author_name: "Reader"
             },
             as: :json
      end.to change(Comment, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(article.reload.comments_count).to eq(1)

      json = JSON.parse(response.body)
      expect(json).to include(
        "body" => "Great post",
        "author_name" => "Reader",
        "article_id" => article.id
      )
    end

    it "returns validation errors with 422" do
      post "/api/articles/#{article.id}/comments",
           params: {
             body: "",
             author_name: ""
           },
           as: :json

      expect(response).to have_http_status(:unprocessable_content)

      json = JSON.parse(response.body)
      expect(json["errors"]).to include("body", "author_name")
    end
  end
end

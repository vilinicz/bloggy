require "rails_helper"

RSpec.describe "Articles API", type: :request do
  describe "GET /api/articles" do
    it "returns articles with required fields sorted by newest first" do
      older = Article.create!(
        title: "Older article",
        body: "Body",
        author_name: "Alice"
      )
      older.comments.create!(body: "First", author_name: "Reader")
      newer = Article.create!(
        title: "Newer article",
        body: "Body",
        author_name: "Bob"
      )

      get "/api/articles", params: { limit: 20 }

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json["items"].map { |item| item["id"] }).to eq([newer.id, older.id])
      expect(json["items"].first.keys).to include(
        "id",
        "title",
        "author_name",
        "created_at",
        "comments_count"
      )
      expect(json["items"].last["comments_count"]).to eq(1)
      expect(json["next_cursor"]).to be_nil
    end

    it "supports cursor pagination" do
      first = Article.create!(title: "Article 1", body: "Body", author_name: "A")
      second = Article.create!(title: "Article 2", body: "Body", author_name: "B")
      third = Article.create!(title: "Article 3", body: "Body", author_name: "C")

      get "/api/articles", params: { limit: 2 }
      expect(response).to have_http_status(:ok)
      first_page = JSON.parse(response.body)

      expect(first_page["items"].map { |item| item["id"] }).to eq([third.id, second.id])
      expect(first_page["next_cursor"]).to be_a(String)

      get "/api/articles", params: {
        limit: 2,
        cursor: first_page["next_cursor"]
      }

      expect(response).to have_http_status(:ok)
      second_page = JSON.parse(response.body)
      expect(second_page["items"].map { |item| item["id"] }).to eq([first.id])
      expect(second_page["next_cursor"]).to be_nil
    end
  end

  describe "GET /api/articles/:id" do
    it "returns article details" do
      article = Article.create!(
        title: "Detailed article",
        body: "Full article body",
        author_name: "Alice"
      )
      article.comments.create!(body: "First comment", author_name: "Reader")

      get "/api/articles/#{article.id}"

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json).to include(
        "id" => article.id,
        "title" => "Detailed article",
        "body" => "Full article body",
        "author_name" => "Alice",
        "comments_count" => 1
      )
      expect(json.keys).to include("created_at", "updated_at")
    end

    it "returns 404 when article does not exist" do
      get "/api/articles/999999"

      expect(response).to have_http_status(:not_found)

      json = JSON.parse(response.body)
      expect(json).to eq("error" => "Not found")
    end
  end

  describe "POST /api/articles" do
    it "creates an article" do
      expect do
        post "/api/articles",
             params: {
               title: "Article title",
               body: "Article body",
               author_name: "Author"
             },
             as: :json
      end.to change(Article, :count).by(1)

      expect(response).to have_http_status(:created)

      json = JSON.parse(response.body)
      expect(json).to include(
        "title" => "Article title",
        "body" => "Article body",
        "author_name" => "Author"
      )
      expect(json["comments_count"]).to eq(0)
    end

    it "returns validation errors with 422" do
      post "/api/articles",
           params: {
             title: "",
             body: "",
             author_name: ""
           },
           as: :json

      expect(response).to have_http_status(:unprocessable_content)

      json = JSON.parse(response.body)
      expect(json["errors"]).to include("title", "body", "author_name")
    end
  end
end

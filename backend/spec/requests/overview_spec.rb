require "rails_helper"

RSpec.describe "Overview API", type: :request do
  describe "GET /api/overview" do
    it "returns totals and most commented articles" do
      low = Article.create!(title: "Low", body: "Body", author_name: "A")
      medium = Article.create!(title: "Medium", body: "Body", author_name: "B")
      high = Article.create!(title: "High", body: "Body", author_name: "C")

      1.times { low.comments.create!(body: "Comment", author_name: "User") }
      2.times { medium.comments.create!(body: "Comment", author_name: "User") }
      3.times { high.comments.create!(body: "Comment", author_name: "User") }

      get "/api/overview"

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json["total_articles"]).to eq(3)
      expect(json["total_comments"]).to eq(6)
      expect(json["most_commented_articles"].map { |item| item["id"] }).to eq([high.id, medium.id, low.id])
    end
  end
end

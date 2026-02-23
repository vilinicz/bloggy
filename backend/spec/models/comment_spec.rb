require "rails_helper"

RSpec.describe Comment, type: :model do
  let(:article) do
    Article.create!(
      title: "Article title",
      body: "Article body",
      author_name: "Author"
    )
  end

  subject(:comment) do
    described_class.new(
      article: article,
      body: "Nice article!",
      author_name: "Bob"
    )
  end

  it "is valid with required attributes" do
    expect(comment).to be_valid
  end

  it "requires body" do
    comment.body = nil

    expect(comment).not_to be_valid
    expect(comment.errors[:body]).to include("can't be blank")
  end

  it "requires author_name" do
    comment.author_name = nil

    expect(comment).not_to be_valid
    expect(comment.errors[:author_name]).to include("can't be blank")
  end

  it "requires an article" do
    comment.article = nil

    expect(comment).not_to be_valid
    expect(comment.errors[:article]).to include("must exist")
  end

  it "limits author_name length to 100 characters" do
    comment.author_name = "a" * 101

    expect(comment).not_to be_valid
    expect(comment.errors[:author_name]).to include("is too long (maximum is 100 characters)")
  end

  it "updates article comments_count through counter cache" do
    expect do
      article.comments.create!(body: "Another comment", author_name: "Jane")
    end.to change { article.reload.comments_count }.by(1)
  end
end

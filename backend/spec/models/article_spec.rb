require "rails_helper"

RSpec.describe Article, type: :model do
  subject(:article) do
    described_class.new(
      title: "Designing reliable APIs",
      body: "A short body",
      author_name: "Alice"
    )
  end

  it "is valid with required attributes" do
    expect(article).to be_valid
  end

  it "requires title" do
    article.title = nil

    expect(article).not_to be_valid
    expect(article.errors[:title]).to include("can't be blank")
  end

  it "requires body" do
    article.body = nil

    expect(article).not_to be_valid
    expect(article.errors[:body]).to include("can't be blank")
  end

  it "requires author_name" do
    article.author_name = nil

    expect(article).not_to be_valid
    expect(article.errors[:author_name]).to include("can't be blank")
  end

  it "limits title length to 200 characters" do
    article.title = "a" * 201

    expect(article).not_to be_valid
    expect(article.errors[:title]).to include("is too long (maximum is 200 characters)")
  end

  it "limits author_name length to 100 characters" do
    article.author_name = "a" * 101

    expect(article).not_to be_valid
    expect(article.errors[:author_name]).to include("is too long (maximum is 100 characters)")
  end
end

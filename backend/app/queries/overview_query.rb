class OverviewQuery
  def call
    {
      total_articles: Article.count,
      total_comments: Comment.count,
      most_commented_articles: most_commented_articles
    }
  end

  private

  def most_commented_articles
    Article
      .select(:id, :title, :author_name, :created_at, :comments_count)
      .order(comments_count: :desc, created_at: :desc, id: :desc)
      .limit(5)
  end
end

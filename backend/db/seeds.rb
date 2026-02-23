# frozen_string_literal: true

require "faker"

ARTICLES_COUNT = 50
MIN_COMMENTS_PER_ARTICLE = 2
MAX_COMMENTS_PER_ARTICLE = 600
MIN_COMMENTS_FOR_LATEST_ARTICLE = 501

RNG = Random.new(42)
Faker::Config.random = RNG

AUTHOR_NAME_POOL = Array.new(350) { Faker::Name.name.truncate(100) }.uniq.freeze
COMMENT_BODY_POOL = Array.new(800) do
  Faker::Lorem.sentences(number: RNG.rand(1..3), supplemental: true).join(" ").truncate(500)
end.freeze

def pick(pool)
  pool[RNG.rand(pool.length)]
end

def realistic_article_body
  paragraph_count = RNG.rand(3..5)

  Array.new(paragraph_count) do
    Faker::Lorem.paragraph(sentence_count: RNG.rand(4..8), supplemental: true)
  end.join("\n\n")
end

def article_timestamps(count, seed_now:)
  timestamps = Array.new(count)
  timestamps[count - 1] = (seed_now - 24.hours).change(usec: 0)

  (count - 2).downto(0) do |index|
    step_minutes = RNG.rand(12 * 60..30 * 60)
    timestamps[index] = timestamps[index + 1] - step_minutes.minutes
  end

  timestamps
end

def comments_counts_for_articles
  counts = Array.new(ARTICLES_COUNT - 1) { RNG.rand(MIN_COMMENTS_PER_ARTICLE..MAX_COMMENTS_PER_ARTICLE) }
  counts << RNG.rand(MIN_COMMENTS_FOR_LATEST_ARTICLE..MAX_COMMENTS_PER_ARTICLE)
  counts
end

def build_article_rows(timestamps:, counts:)
  timestamps.each_with_index.map do |created_at, index|
    {
      title: Faker::Book.title.truncate(200),
      body: realistic_article_body,
      author_name: pick(AUTHOR_NAME_POOL),
      comments_count: counts[index],
      created_at: created_at,
      updated_at: created_at
    }
  end
end

def comment_timestamps(start_time:, end_time:, count:)
  return [start_time.change(usec: 0)] if count == 1
  return Array.new(count, start_time.change(usec: 0)) if end_time <= start_time

  total_minutes = ((end_time - start_time) / 60).floor
  return Array.new(count, start_time.change(usec: 0)) if total_minutes <= 0

  step = total_minutes.to_f / (count - 1)

  Array.new(count) do |index|
    (start_time + (index * step).round.minutes).change(usec: 0)
  end
end

def build_comment_rows(article:, count:, seed_now:)
  hour_start = article.created_at.beginning_of_hour
  first_comment_time = [hour_start + RNG.rand(0..59).minutes, article.created_at].max.change(usec: 0)
  last_comment_time = [article.created_at + 24.hours, seed_now].min.change(usec: 0)
  timestamps = comment_timestamps(start_time: first_comment_time, end_time: last_comment_time, count: count)

  timestamps.map do |timestamp|
    {
      article_id: article.id,
      body: pick(COMMENT_BODY_POOL),
      author_name: pick(AUTHOR_NAME_POOL),
      created_at: timestamp,
      updated_at: timestamp
    }
  end
end

puts "Seeding articles and comments..."
start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
seed_now = Time.current.change(usec: 0)

# Postgres only
ActiveRecord::Base.transaction do
  ActiveRecord::Base.connection.execute("TRUNCATE TABLE comments, articles RESTART IDENTITY CASCADE")
  timestamps = article_timestamps(ARTICLES_COUNT, seed_now: seed_now)
  comment_counts = comments_counts_for_articles

  Article.insert_all!(build_article_rows(timestamps: timestamps, counts: comment_counts))

  articles = Article.order(:created_at, :id).to_a
  articles.zip(comment_counts).each do |article, count|
    Comment.insert_all!(build_comment_rows(article: article, count: count, seed_now: seed_now))
  end
end

latest_article = Article.order(created_at: :desc, id: :desc).first
elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time

puts "Seed complete:"
puts "- Articles: #{Article.count}"
puts "- Comments: #{Comment.count}"
puts "- Latest article ID: #{latest_article.id}"
puts "- Latest article created_at: #{latest_article.created_at}"
puts "- Latest article comments_count: #{latest_article.comments_count}"
puts "- Runtime: #{elapsed.round(2)}s"

export type Cursor = string;

export interface PaginatedResponse<T> {
  items: T[];
  next_cursor: Cursor | null;
}

export interface ArticleListItem {
  id: number;
  title: string;
  author_name: string;
  created_at: string;
  comments_count: number;
}

export interface Article extends ArticleListItem {
  body: string;
}

export interface Comment {
  id: number;
  body: string;
  author_name: string;
  article_id: number;
  created_at: string;
}

export interface OverviewResponse {
  total_articles: number;
  total_comments: number;
  most_commented_articles: ArticleListItem[];
}

export interface ValidationErrorsResponse {
  errors: Record<string, string[]>;
}

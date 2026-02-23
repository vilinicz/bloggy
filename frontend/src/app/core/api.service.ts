import { HttpClient, HttpParams } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable, timeout } from 'rxjs';
import {
  Article,
  ArticleListItem,
  Comment,
  Cursor,
  OverviewResponse,
  PaginatedResponse,
} from './api.models';

@Injectable({ providedIn: 'root' })
export class ApiService {
  private readonly http = inject(HttpClient);
  private readonly baseUrl = '/api';
  private readonly requestTimeoutMs = 10_000;

  getArticles(limit: number, cursor: Cursor | null): Observable<PaginatedResponse<ArticleListItem>> {
    return this.http
      .get<PaginatedResponse<ArticleListItem>>(`${this.baseUrl}/articles`, {
        params: this.buildCursorParams(limit, cursor),
      })
      .pipe(timeout(this.requestTimeoutMs));
  }

  getArticle(id: number): Observable<Article> {
    return this.http.get<Article>(`${this.baseUrl}/articles/${id}`).pipe(timeout(this.requestTimeoutMs));
  }

  createArticle(payload: Pick<Article, 'title' | 'body' | 'author_name'>): Observable<Article> {
    return this.http
      .post<Article>(`${this.baseUrl}/articles`, payload)
      .pipe(timeout(this.requestTimeoutMs));
  }

  getComments(
    articleId: number,
    limit: number,
    cursor: Cursor | null,
  ): Observable<PaginatedResponse<Comment>> {
    return this.http
      .get<PaginatedResponse<Comment>>(`${this.baseUrl}/articles/${articleId}/comments`, {
        params: this.buildCursorParams(limit, cursor),
      })
      .pipe(timeout(this.requestTimeoutMs));
  }

  createComment(
    articleId: number,
    payload: Pick<Comment, 'body' | 'author_name'>,
  ): Observable<Comment> {
    return this.http
      .post<Comment>(`${this.baseUrl}/articles/${articleId}/comments`, payload)
      .pipe(timeout(this.requestTimeoutMs));
  }

  getOverview(): Observable<OverviewResponse> {
    return this.http.get<OverviewResponse>(`${this.baseUrl}/overview`).pipe(timeout(this.requestTimeoutMs));
  }

  private buildCursorParams(limit: number, cursor: Cursor | null): HttpParams {
    let params = new HttpParams().set('limit', String(limit));

    if (!cursor) {
      return params;
    }

    params = params.set('cursor', cursor);

    return params;
  }
}

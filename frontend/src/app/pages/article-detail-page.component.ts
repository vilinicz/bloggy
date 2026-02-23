import { DatePipe } from '@angular/common';
import {
  AfterViewInit,
  Component,
  ElementRef,
  OnDestroy,
  OnInit,
  ViewChild,
  inject,
} from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { ActivatedRoute } from '@angular/router';
import { finalize } from 'rxjs';
import { ApiService } from '../core/api.service';
import { Article, Comment, Cursor } from '../core/api.models';
import { formatValidationError } from '../core/http-errors';

@Component({
  selector: 'app-article-detail-page',
  imports: [DatePipe, ReactiveFormsModule],
  templateUrl: './article-detail-page.component.html',
  styleUrl: './article-detail-page.component.css',
})
export class ArticleDetailPageComponent implements OnInit, AfterViewInit, OnDestroy {
  private readonly api = inject(ApiService);
  private readonly fb = inject(FormBuilder);
  private readonly route = inject(ActivatedRoute);

  private observer: IntersectionObserver | null = null;

  @ViewChild('commentSentinel', { static: true })
  commentSentinel!: ElementRef<HTMLDivElement>;

  article: Article | null = null;
  articleLoading = true;
  articleError = '';

  comments: Comment[] = [];
  commentsCursor: Cursor | null = null;
  commentsLoaded = false;
  commentsLoading = false;
  commentsError = '';

  postingComment = false;
  commentError = '';

  readonly commentsPageSize = 30;

  readonly commentForm = this.fb.nonNullable.group({
    body: ['', [Validators.required]],
    author_name: ['', [Validators.required, Validators.maxLength(100)]],
  });

  ngOnInit(): void {
    const articleId = this.articleId;
    if (!articleId) {
      this.articleError = 'Invalid article id.';
      this.articleLoading = false;
      return;
    }

    this.loadArticle(articleId);
  }

  ngAfterViewInit(): void {
    this.observer = new IntersectionObserver(
      (entries) => {
        const articleId = this.articleId;
        if (entries.some((entry) => entry.isIntersecting) && articleId) {
          this.loadNextComments(articleId);
        }
      },
      { rootMargin: '350px 0px' },
    );

    this.observer.observe(this.commentSentinel.nativeElement);
  }

  ngOnDestroy(): void {
    this.observer?.disconnect();
  }

  submitComment(): void {
    const articleId = this.articleId;
    if (!articleId) {
      return;
    }

    if (this.commentForm.invalid) {
      this.commentForm.markAllAsTouched();
      return;
    }

    this.postingComment = true;
    this.commentError = '';

    this.api.createComment(articleId, this.commentForm.getRawValue()).subscribe({
      next: (comment) => {
        this.comments = [comment, ...this.comments];
        if (this.article) {
          this.article = {
            ...this.article,
            comments_count: this.article.comments_count + 1,
          };
        }

        this.postingComment = false;
        this.commentForm.reset({ body: '', author_name: '' });
      },
      error: (error: unknown) => {
        this.postingComment = false;
        this.commentError = formatValidationError(error);
      },
    });
  }

  private get articleId(): number | null {
    const id = Number(this.route.snapshot.paramMap.get('id'));
    if (!Number.isInteger(id) || id <= 0) {
      return null;
    }

    return id;
  }

  private loadArticle(articleId: number): void {
    this.articleLoading = true;
    this.articleError = '';

    this.api
      .getArticle(articleId)
      .pipe(finalize(() => (this.articleLoading = false)))
      .subscribe({
        next: (article) => {
          this.article = article;
          this.loadNextComments(articleId);
        },
        error: () => {
          this.articleError = 'Failed to load article.';
        },
      });
  }

  private loadNextComments(articleId: number): void {
    if (!this.article) {
      return;
    }

    if (this.commentsLoading) {
      return;
    }

    if (this.commentsLoaded && this.commentsCursor === null) {
      return;
    }

    this.commentsLoading = true;
    this.commentsError = '';

    const cursor = this.commentsLoaded ? this.commentsCursor : null;

    this.api
      .getComments(articleId, this.commentsPageSize, cursor)
      .pipe(finalize(() => (this.commentsLoading = false)))
      .subscribe({
        next: (response) => {
          this.comments = [...this.comments, ...response.items];
          this.commentsCursor = response.next_cursor ?? null;
          this.commentsLoaded = true;
        },
        error: () => {
          this.commentsError = 'Failed to load comments.';
        },
      });
  }
}

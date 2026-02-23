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
import { RouterLink } from '@angular/router';
import { finalize } from 'rxjs';
import { ApiService } from '../core/api.service';
import { ArticleListItem, Cursor } from '../core/api.models';

@Component({
  selector: 'app-articles-page',
  imports: [RouterLink, DatePipe],
  templateUrl: './articles-page.component.html',
  styleUrl: './articles-page.component.css',
})
export class ArticlesPageComponent implements OnInit, AfterViewInit, OnDestroy {
  private readonly api = inject(ApiService);
  private observer: IntersectionObserver | null = null;

  @ViewChild('sentinel', { static: true })
  sentinel!: ElementRef<HTMLDivElement>;

  readonly pageSize = 20;

  articles: ArticleListItem[] = [];
  nextCursor: Cursor | null = null;
  loading = false;
  loaded = false;
  errorMessage = '';

  ngOnInit(): void {
    this.loadNextPage();
  }

  ngAfterViewInit(): void {
    this.observer = new IntersectionObserver(
      (entries) => {
        if (entries.some((entry) => entry.isIntersecting)) {
          this.loadNextPage();
        }
      },
      { rootMargin: '350px 0px' },
    );

    this.observer.observe(this.sentinel.nativeElement);
  }

  ngOnDestroy(): void {
    this.observer?.disconnect();
  }

  loadNextPage(): void {
    if (this.loading) {
      return;
    }

    if (this.loaded && this.nextCursor === null) {
      return;
    }

    this.loading = true;
    this.errorMessage = '';

    const cursor = this.loaded ? this.nextCursor : null;

    this.api
      .getArticles(this.pageSize, cursor)
      .pipe(finalize(() => (this.loading = false)))
      .subscribe({
        next: (response) => {
          this.articles = [...this.articles, ...response.items];
          this.nextCursor = response.next_cursor ?? null;
          this.loaded = true;
        },
        error: () => {
          this.errorMessage = 'Failed to load articles. Please refresh the page.';
        },
      });
  }
}

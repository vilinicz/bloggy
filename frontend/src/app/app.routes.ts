import { Routes } from '@angular/router';

export const routes: Routes = [
  {
    path: '',
    pathMatch: 'full',
    redirectTo: 'articles',
  },
  {
    path: 'articles',
    loadComponent: () =>
      import('./pages/articles-page.component').then((m) => m.ArticlesPageComponent),
  },
  {
    path: 'articles/new',
    loadComponent: () =>
      import('./pages/article-form-page.component').then((m) => m.ArticleFormPageComponent),
  },
  {
    path: 'articles/:id',
    loadComponent: () =>
      import('./pages/article-detail-page.component').then((m) => m.ArticleDetailPageComponent),
  },
  {
    path: 'overview',
    loadComponent: () =>
      import('./pages/overview-page.component').then((m) => m.OverviewPageComponent),
  },
  {
    path: '**',
    redirectTo: 'articles',
  },
];

import { Component, inject } from '@angular/core';
import { ReactiveFormsModule, Validators, FormBuilder } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { ApiService } from '../core/api.service';
import { formatValidationError } from '../core/http-errors';

@Component({
  selector: 'app-article-form-page',
  imports: [ReactiveFormsModule, RouterLink],
  templateUrl: './article-form-page.component.html',
  styleUrl: './article-form-page.component.css',
})
export class ArticleFormPageComponent {
  private readonly api = inject(ApiService);
  private readonly fb = inject(FormBuilder);
  private readonly router = inject(Router);

  saving = false;
  errorMessage = '';

  readonly form = this.fb.nonNullable.group({
    title: ['', [Validators.required, Validators.maxLength(200)]],
    body: ['', [Validators.required]],
    author_name: ['', [Validators.required, Validators.maxLength(100)]],
  });

  submit(): void {
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }

    this.saving = true;
    this.errorMessage = '';

    this.api.createArticle(this.form.getRawValue()).subscribe({
      next: (article) => {
        this.saving = false;
        this.router.navigate(['/articles', article.id]);
      },
      error: (error: unknown) => {
        this.saving = false;
        this.errorMessage = formatValidationError(error);
      },
    });
  }
}

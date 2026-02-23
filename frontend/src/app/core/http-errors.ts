import { HttpErrorResponse } from '@angular/common/http';
import { ValidationErrorsResponse } from './api.models';

export function formatValidationError(error: unknown): string {
  if (!(error instanceof HttpErrorResponse)) {
    return 'Unexpected error. Please try again.';
  }

  if (error.status >= 500) {
    return 'Server error. Please try again in a moment.';
  }

  if (error.status !== 422 || !error.error) {
    return 'Request failed. Please check your input.';
  }

  const payload = error.error as ValidationErrorsResponse;
  if (!payload.errors) {
    return 'Validation failed.';
  }

  return Object.entries(payload.errors)
    .map(([field, messages]) => `${field} ${messages.join(', ')}`)
    .join(' | ');
}

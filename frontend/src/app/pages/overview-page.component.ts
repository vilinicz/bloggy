import { DatePipe } from '@angular/common';
import { Component, OnInit, inject } from '@angular/core';
import { RouterLink } from '@angular/router';
import { finalize } from 'rxjs';
import { ApiService } from '../core/api.service';
import { OverviewResponse } from '../core/api.models';

@Component({
  selector: 'app-overview-page',
  imports: [RouterLink, DatePipe],
  templateUrl: './overview-page.component.html',
  styleUrl: './overview-page.component.css',
})
export class OverviewPageComponent implements OnInit {
  private readonly api = inject(ApiService);

  data: OverviewResponse | null = null;
  loading = true;
  errorMessage = '';

  ngOnInit(): void {
    this.api
      .getOverview()
      .pipe(finalize(() => (this.loading = false)))
      .subscribe({
        next: (response) => {
          this.data = response;
        },
        error: () => {
          this.errorMessage = 'Failed to load overview.';
        },
      });
  }
}

import { Component, inject, computed } from '@angular/core';
import { RouterOutlet, RouterLink, RouterLinkActive, Router } from '@angular/router';
import { MatSidenavModule } from '@angular/material/sidenav';
import { MatToolbarModule } from '@angular/material/toolbar';
import { MatListModule } from '@angular/material/list';
import { MatIconModule } from '@angular/material/icon';
import { MatButtonModule } from '@angular/material/button';
import { MatMenuModule } from '@angular/material/menu';
import { MatTooltipModule } from '@angular/material/tooltip';
import { MatDividerModule } from '@angular/material/divider';
import { CommonModule } from '@angular/common';
import { BreakpointObserver, Breakpoints } from '@angular/cdk/layout';
import { Observable } from 'rxjs';
import { map, shareReplay } from 'rxjs/operators';
import { AuthService } from './core/services/auth.service';
import { MatDialog, MatDialogModule } from '@angular/material/dialog';
import { ClientForm } from './features/client-form/client-form';
import { ProposalForm } from './features/proposal-form/proposal-form';
import { CompanyForm } from './features/company-form/company-form';

@Component({
  selector: 'app-root',
  imports: [
    RouterOutlet,
    RouterLink,
    RouterLinkActive,
    MatSidenavModule,
    MatToolbarModule,
    MatListModule,
    MatIconModule,
    MatButtonModule,
    MatMenuModule,
    MatTooltipModule,
    MatDividerModule,
    MatDialogModule,
    CommonModule
  ],
  templateUrl: './app.html',
  styleUrl: './app.scss'
})
export class App {
  private breakpointObserver = inject(BreakpointObserver);
  readonly auth = inject(AuthService);
  private dialog = inject(MatDialog);
  private router = inject(Router);

  isHandset$: Observable<boolean> = this.breakpointObserver.observe('(max-width: 959px)')
    .pipe(map(result => result.matches), shareReplay());

  readonly userInitials = computed(() => {
    const name = this.auth.currentUser()?.nome || '';
    return name.split(' ').slice(0, 2).map(w => w[0]?.toUpperCase() || '').join('');
  });

  readonly canSeeSettings = computed(() =>
    this.auth.isSuperAdmin() || this.auth.hasPermission('settings.read')
  );

  readonly canSeeSupervisor = computed(() =>
    this.auth.isSuperAdmin() || this.auth.hasPermission('supervisor.access')
  );

  logout(): void {
    this.auth.logout();
  }

  openNewClient(): void {
    const dialogRef = this.dialog.open(ClientForm, {
      width: '600px',
      data: null
    });
    dialogRef.afterClosed().subscribe(result => {
      if (result) {
        if (this.router.url.startsWith('/clientes')) {
          window.location.reload();
        } else {
          this.router.navigate(['/clientes']);
        }
      }
    });
  }

  openNewProposal(): void {
    const dialogRef = this.dialog.open(ProposalForm, {
      width: '700px',
      data: null
    });
    dialogRef.afterClosed().subscribe(result => {
      if (result) {
        if (this.router.url.startsWith('/propostas')) {
          window.location.reload();
        } else {
          this.router.navigate(['/propostas']);
        }
      }
    });
  }

  openNewCompany(): void {
    const dialogRef = this.dialog.open(CompanyForm, {
      width: '650px',
      data: null
    });
    dialogRef.afterClosed().subscribe(result => {
      if (result) {
        if (this.router.url.startsWith('/configuracoes')) {
          window.location.reload();
        } else {
          this.router.navigate(['/configuracoes']);
        }
      }
    });
  }
}

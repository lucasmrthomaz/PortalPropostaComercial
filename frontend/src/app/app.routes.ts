import { Routes } from '@angular/router';
import { authGuard } from './core/guards/auth.guard';

export const routes: Routes = [
  // Public
  { path: 'login', loadComponent: () => import('./features/login/login').then(m => m.LoginPage) },

  // Protected — all routes require authentication
  { path: '', redirectTo: 'dashboard', pathMatch: 'full' },
  { path: 'dashboard',    canActivate: [authGuard], loadComponent: () => import('./features/dashboard/dashboard').then(m => m.Dashboard) },
  { path: 'clientes',     canActivate: [authGuard], loadComponent: () => import('./features/client-list/client-list').then(m => m.ClientList) },
  { path: 'propostas',    canActivate: [authGuard], loadComponent: () => import('./features/proposal-list/proposal-list').then(m => m.ProposalList) },
  { path: 'empresas',     canActivate: [authGuard], loadComponent: () => import('./features/company-list/company-list').then(m => m.CompanyList) },
  { path: 'configuracoes',canActivate: [authGuard], loadComponent: () => import('./features/settings/settings').then(m => m.SettingsComponent) },
  { path: 'supervisor',   canActivate: [authGuard], loadComponent: () => import('./features/supervisor-panel/supervisor-panel').then(m => m.SupervisorPanel) },
  { path: '**', redirectTo: 'dashboard' }
];

import { Injectable, signal, computed } from '@angular/core';
import { Router } from '@angular/router';
import { HttpClient } from '@angular/common/http';
import { tap } from 'rxjs/operators';
import { Observable } from 'rxjs';
import { Usuario, LoginRequest } from '../models/user.model';

const STORAGE_KEY = 'portal_user';

@Injectable({ providedIn: 'root' })
export class AuthService {
  private _currentUser = signal<Usuario | null>(this.loadFromStorage());

  readonly currentUser = this._currentUser.asReadonly();

  readonly isLoggedIn = computed(() => !!this._currentUser());

  readonly isSuperAdmin = computed(() => {
    const user = this._currentUser();
    return user?.perfil?.nome === 'Super Admin';
  });

  readonly permissoes = computed((): string[] => {
    const user = this._currentUser();
    if (!user?.perfil?.permissoes) return [];
    let perms = user.perfil.permissoes;
    if (typeof perms === 'string') {
      try { perms = JSON.parse(perms); } catch { return []; }
    }
    return perms as string[];
  });

  constructor(private http: HttpClient, private router: Router) {}

  login(req: LoginRequest): Observable<Usuario> {
    return this.http.post<Usuario>('http://localhost:8080/api/auth/login', req).pipe(
      tap(user => {
        this._currentUser.set(user);
        localStorage.setItem(STORAGE_KEY, JSON.stringify(user));
      })
    );
  }

  logout(): void {
    this._currentUser.set(null);
    localStorage.removeItem(STORAGE_KEY);
    this.router.navigate(['/login']);
  }

  hasPermission(permission: string): boolean {
    if (this.isSuperAdmin()) return true;
    const perms = this.permissoes();
    return perms.includes('*') || perms.includes(permission);
  }

  private loadFromStorage(): Usuario | null {
    try {
      const raw = localStorage.getItem(STORAGE_KEY);
      return raw ? JSON.parse(raw) : null;
    } catch {
      return null;
    }
  }
}

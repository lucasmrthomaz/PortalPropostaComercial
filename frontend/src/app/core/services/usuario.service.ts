import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { Usuario, LoginRequest } from '../models/user.model';

@Injectable({ providedIn: 'root' })
export class UsuarioService {
  private http = inject(HttpClient);
  private baseUrl = 'http://localhost:8080/api/users';
  private authUrl = 'http://localhost:8080/api/auth';

  list(): Observable<Usuario[]> {
    return this.http.get<Usuario[]>(this.baseUrl);
  }

  getById(id: string): Observable<Usuario> {
    return this.http.get<Usuario>(`${this.baseUrl}/${id}`);
  }

  create(usuario: Usuario & { senha: string }): Observable<Usuario> {
    return this.http.post<Usuario>(this.baseUrl, usuario);
  }

  update(id: string, usuario: Partial<Usuario> & { senha?: string }): Observable<Usuario> {
    return this.http.put<Usuario>(`${this.baseUrl}/${id}`, usuario);
  }

  delete(id: string): Observable<void> {
    return this.http.delete<void>(`${this.baseUrl}/${id}`);
  }

  login(req: LoginRequest): Observable<Usuario> {
    return this.http.post<Usuario>(`${this.authUrl}/login`, req);
  }
}

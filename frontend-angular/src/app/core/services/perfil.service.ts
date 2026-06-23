import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { Perfil } from '../models/user.model';

@Injectable({ providedIn: 'root' })
export class PerfilService {
  private http = inject(HttpClient);
  private baseUrl = 'http://localhost:8080/api/profiles';

  list(): Observable<Perfil[]> {
    return this.http.get<Perfil[]>(this.baseUrl);
  }

  getById(id: string): Observable<Perfil> {
    return this.http.get<Perfil>(`${this.baseUrl}/${id}`);
  }

  create(perfil: Perfil): Observable<Perfil> {
    return this.http.post<Perfil>(this.baseUrl, perfil);
  }

  update(id: string, perfil: Perfil): Observable<Perfil> {
    return this.http.put<Perfil>(`${this.baseUrl}/${id}`, perfil);
  }

  delete(id: string): Observable<void> {
    return this.http.delete<void>(`${this.baseUrl}/${id}`);
  }
}

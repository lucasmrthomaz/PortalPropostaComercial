import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { PedidoAnalise } from '../models/supervisor.model';

@Injectable({
  providedIn: 'root'
})
export class SupervisorService {
  private http = inject(HttpClient);
  private apiUrl = '/api/supervisor';

  verifyPassword(password: string): Observable<{ valid: boolean }> {
    return this.http.post<{ valid: boolean }>(`${this.apiUrl}/verify-password`, { password });
  }

  list(status?: string): Observable<PedidoAnalise[]> {
    const url = status ? `${this.apiUrl}/requests?status=${status}` : `${this.apiUrl}/requests`;
    return this.http.get<PedidoAnalise[]>(url);
  }

  createRequest(request: PedidoAnalise): Observable<PedidoAnalise> {
    return this.http.post<PedidoAnalise>(`${this.apiUrl}/requests`, request);
  }

  approve(id: string): Observable<any> {
    return this.http.post(`${this.apiUrl}/requests/${id}/approve`, {});
  }

  reject(id: string): Observable<any> {
    return this.http.post(`${this.apiUrl}/requests/${id}/reject`, {});
  }
}

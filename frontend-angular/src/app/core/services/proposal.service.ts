import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { Proposta } from '../models/proposal.model';
import { DashboardStats } from '../models/stats.model';

@Injectable({
  providedIn: 'root'
})
export class ProposalService {
  private http = inject(HttpClient);
  private apiUrl = '/api/proposals';

  list(): Observable<Proposta[]> {
    return this.http.get<Proposta[]>(this.apiUrl);
  }

  get(id: string): Observable<Proposta> {
    return this.http.get<Proposta>(`${this.apiUrl}/${id}`);
  }

  create(proposal: Proposta): Observable<Proposta> {
    return this.http.post<Proposta>(this.apiUrl, proposal);
  }

  update(id: string, proposal: Proposta): Observable<Proposta> {
    return this.http.put<Proposta>(`${this.apiUrl}/${id}`, proposal);
  }

  delete(id: string): Observable<any> {
    return this.http.delete(`${this.apiUrl}/${id}`);
  }

  getStats(): Observable<DashboardStats> {
    return this.http.get<DashboardStats>('/api/dashboard/stats');
  }
}

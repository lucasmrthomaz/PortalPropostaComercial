import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { TipoProposta } from '../models/proposal-type.model';

@Injectable({
  providedIn: 'root'
})
export class ProposalTypeService {
  private http = inject(HttpClient);
  private apiUrl = '/api/proposal-types';

  list(): Observable<TipoProposta[]> {
    return this.http.get<TipoProposta[]>(this.apiUrl);
  }

  get(id: string): Observable<TipoProposta> {
    return this.http.get<TipoProposta>(`${this.apiUrl}/${id}`);
  }

  create(tipo: TipoProposta): Observable<TipoProposta> {
    return this.http.post<TipoProposta>(this.apiUrl, tipo);
  }

  update(id: string, tipo: TipoProposta): Observable<TipoProposta> {
    return this.http.put<TipoProposta>(`${this.apiUrl}/${id}`, tipo);
  }

  delete(id: string): Observable<any> {
    return this.http.delete(`${this.apiUrl}/${id}`);
  }
}

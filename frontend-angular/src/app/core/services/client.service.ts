import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { Cliente } from '../models/client.model';

@Injectable({
  providedIn: 'root'
})
export class ClientService {
  private http = inject(HttpClient);
  private apiUrl = '/api/clients';

  list(): Observable<Cliente[]> {
    return this.http.get<Cliente[]>(this.apiUrl);
  }

  get(id: string): Observable<Cliente> {
    return this.http.get<Cliente>(`${this.apiUrl}/${id}`);
  }

  create(client: Cliente): Observable<Cliente> {
    return this.http.post<Cliente>(this.apiUrl, client);
  }

  update(id: string, client: Cliente): Observable<Cliente> {
    return this.http.put<Cliente>(`${this.apiUrl}/${id}`, client);
  }

  delete(id: string): Observable<any> {
    return this.http.delete(`${this.apiUrl}/${id}`);
  }

  getProposals(id: string): Observable<any[]> {
    return this.http.get<any[]>(`${this.apiUrl}/${id}/proposals`);
  }
}

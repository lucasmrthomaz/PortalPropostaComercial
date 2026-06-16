import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { Settings } from '../models/settings.model';

@Injectable({
  providedIn: 'root'
})
export class SettingsService {
  private http = inject(HttpClient);
  private apiUrl = '/api/settings';

  get(): Observable<Settings> {
    return this.http.get<Settings>(this.apiUrl);
  }

  update(settings: Settings): Observable<any> {
    return this.http.put(this.apiUrl, settings);
  }
}

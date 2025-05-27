import { HttpClient } from "@angular/common/http";
import { Injectable } from "@angular/core";
import { Observable } from "rxjs";
import { environment } from "src/environments/environment";

@Injectable({
  providedIn: 'root',
})
export class GreetingService {
  private baseUrl = environment.backendURI;

  constructor(private http: HttpClient) {}

  getGreeting(name?: string): Observable<string> {
    const params = name ? `?name=${encodeURIComponent(name)}` : '';
    return this.http.get(`${this.baseUrl}/home${params}`, { responseType: 'text' });
  }
}

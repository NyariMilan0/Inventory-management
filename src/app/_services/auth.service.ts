import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { tap } from 'rxjs/operators';

@Injectable({ providedIn: 'root' })
export class AuthService {
  private apiUrl = 'http://127.0.0.1:8080/raktarproject-1.0-SNAPSHOT/webresources/user/login';

  constructor(private http: HttpClient) {}

  login(username: string, password: string) {
    return this.http.post<any>(this.apiUrl, { userName: username, password }).pipe(
      tap(res => {
        localStorage.setItem('jwtToken', res.result.jwt);
        localStorage.setItem('userName', res.result.userName);
        localStorage.setItem('firstName', res.result.firstName);
        localStorage.setItem('lastName', res.result.lastName);
        localStorage.setItem('email', res.result.email);
      })
    );
  }

  logout() {
    localStorage.clear();
  }
}
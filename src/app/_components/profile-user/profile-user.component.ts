import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { AuthService } from '../../_services/auth.service';
import { NavbarComponent } from '../navbar/navbar.component';

@Component({
  selector: 'app-profile-user',
  standalone: true,
  imports: [],
  templateUrl: './profile-user.component.html',
  styleUrl: './profile-user.component.css'
})
export class ProfileUserComponent {
  userName = '';
  firstName = '';
  lastName = '';
  email = '';
  message = '';

  constructor(
    private auth: AuthService,
    private router: Router
  ) {}

  ngOnInit() {
    this.userName = localStorage.getItem('userName') || '';
    this.firstName = localStorage.getItem('firstName') || '';
    this.lastName = localStorage.getItem('lastName') || '';
    this.email = localStorage.getItem('email') || '';
  }

  logout() {
    this.auth.logout();
    this.message = 'Logout successful';
    setTimeout(() => this.router.navigate(['/login']), 1500);
  }
}

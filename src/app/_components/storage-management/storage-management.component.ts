import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { AuthService } from '../../_services/auth.service';
import { NavbarComponent } from '../navbar/navbar.component';

@Component({
  standalone: true,
  templateUrl: '../storage-management/storage-management.component.html',
  styleUrls: ['../storage-management/storage-management.component.css'],
  imports: [NavbarComponent]
})
export class StorageManagementComponent implements OnInit{
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

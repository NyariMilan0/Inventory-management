import { Component } from '@angular/core';
import { StorageManagementComponent } from '../storage-management/storage-management.component';
import { Router } from '@angular/router';

@Component({
  selector: 'app-navbar',
  standalone: true,
  imports: [],
  templateUrl: './navbar.component.html',
  styleUrl: './navbar.component.css'
})
export class NavbarComponent {
  // message = '';
  //   constructor(
  //     private router: Router
  //   ) {}
  isExpanded = false;
  // logout(){
  //   this.message = 'Logout successful';
  //   setTimeout(() => this.router.navigate(['/login']), 1500);
  }


import { Component } from '@angular/core';
import { Router, RouterModule } from '@angular/router'; 

@Component({
  selector: 'app-navbar',
  standalone: true,
  imports: [RouterModule], 
  templateUrl: './navbar.component.html',
  styleUrl: './navbar.component.css'
})
export class NavbarComponent {
  isExpanded = false;
  menuItems = [
    { path: '/storage', icon: 'DiagramIcon.svg', text: 'Storage' },
    { path: '/profileUser', icon: 'profileIcon.svg', text: 'profileUser' },
    { path: '/pallet-management', icon: 'PalletIcon.svg', text: 'Pallet Management' }, ]
}
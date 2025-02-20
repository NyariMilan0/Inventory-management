import { Component, HostListener } from '@angular/core';
import { RouterModule } from '@angular/router';

@Component({
  selector: 'app-navbar',
  standalone: true,
  imports: [RouterModule],
  templateUrl: './navbar.component.html',
  styleUrl: './navbar.component.css'
})
export class NavbarComponent {
  isExpanded = false;
  // Make sidebar visible by default
  isVisible = true;

  @HostListener('mouseenter') onMouseEnter() {
    this.isExpanded = true;
  }

  @HostListener('mouseleave') onMouseLeave() {
    this.isExpanded = false;
  }

  menuItems = [
    { path: '/storage', icon: 'DiagramIcon.svg', text: 'Storage' },
    { path: '/profileAdmin', icon: 'profileIcon.svg', text: 'User Profile' },
    { path: '/pallet-management', icon: 'PalletIcon.svg', text: 'Pallet Management' },
  ];
}
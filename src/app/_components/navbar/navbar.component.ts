import { Component, HostListener } from '@angular/core';
import { RouterModule, Router } from '@angular/router';
import { CommonModule } from '@angular/common';
import { AuthService } from '../../_services/auth.service';
import { ModalService } from '../../_services/modal.service';


@Component({
  selector: 'app-navbar',
  standalone: true,
  imports: [RouterModule, CommonModule],
  templateUrl: './navbar.component.html',
  styleUrls: ['./navbar.component.css']
})
export class NavbarComponent {
  isExpanded = false;
  isVisible = true;
  isMobile = window.innerWidth <= 768;

  constructor(
    private authService: AuthService,
    private router: Router,
    private modalService: ModalService
  ) {}

  @HostListener('window:resize', ['$event'])
  onResize(event: Event) {
    this.isMobile = window.innerWidth <= 768;
    if (!this.isMobile) {
      this.isExpanded = false;
    }
  }

  @HostListener('mouseenter') onMouseEnter() {
    if (!this.isMobile) {
      this.isExpanded = true;
    }
  }

  @HostListener('mouseleave') onMouseLeave() {
    if (!this.isMobile) {
      this.isExpanded = false;
    }
  }

  toggleMenu() {
    if (this.isMobile) {
      this.isExpanded = !this.isExpanded;
    }
  }

  menuItems = [
    { path: '/storage', icon: 'DiagramIcon.svg', text: 'Storage' },
    { path: '/pallet-management', icon: 'PalletIcon.svg', text: 'Pallet Management' },
  ];

  openProfileModal(): void {
    this.modalService.openProfileModal();
  }
  openAdminModal(): void {
    this.modalService.openAdminModal();
  }

  logout(): void {
    this.authService.logout();
    this.router.navigate(['/login']);
  }
}
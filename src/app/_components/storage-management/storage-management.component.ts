import { Component } from '@angular/core';
import { NavbarComponent } from '../navbar/navbar.component';
import { AuthService } from '../../_services/auth.service';
import { Router } from '@angular/router';

@Component({
  standalone: true,
  selector: 'app-warehouse-dashboard',
  templateUrl: './storage-management.component.html',
  styleUrls: ['./storage-management.component.css'],
  imports: [NavbarComponent]
})
export class StorageManagementComponent {


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
 // Lekérdezés, hogy ott van-e még
console.log(localStorage.getItem("jwtToken")); // Kiírja a tokent, ha még ott van

// Ha meg akarod tartani, nem kell semmit tenni
// Ha törölni akarod:
localStorage.removeItem("jwtToken");
    this.auth.logout();
    this.message = 'Logout successful';
    setTimeout(() => this.router.navigate(['/login']), 1500);
  }
}
  // section01Usage = 62.5;
  // warehouseCapacityPercentage = 62.5;
  // section01Slots = Array(40).fill({}).map((_, i) => ({ used: i < 15 }));

  // sections = [
  //   { id: '02', date: '2023/04/06', usage: 62.5 },
  //   { id: '03', date: '2023/04/06', usage: 62.5 },
  //   { id: '04', date: '2023/04/06', usage: 62.5 },
  //   { id: '05', date: '2023/04/06', usage: 62.5 },
  //   { id: '06', date: '2023/04/06', usage: 90 }
  // ];

  // lowStockItems = [
  //   { category: '01', name: 'Name', stock: 10 },
  //   { category: '02', name: 'Name', stock: 10 },
  //   { category: '03', name: 'Name', stock: 10 },
  //   { category: '04', name: 'Name', stock: 10 }
  // ];

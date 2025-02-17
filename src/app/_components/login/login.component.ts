import { Component } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { AuthService } from '../../_services/auth.service';
import { delay } from 'rxjs';


@Component({
  standalone: true,
  imports: [FormsModule],
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.css']
})
export class LoginComponent {
  username = '';
  password = '';
  message = '';
  messageClass = '';

  constructor(
    private auth: AuthService,
    private router: Router
  ) {}

  // ************************** Timer nélküli login - Azonnal bedob login után
//   onSubmit() {
//     this.auth.login(this.username, this.password).subscribe({
//       next: () => this.router.navigate(['/dashboard'] ),
//       error: (err) => {
//         this.messageClass = 'error';
//         this.message = err.error?.message || 'Nem létezik ilyen felhasználó!';
//       }
//     });
//   }
// }
 // ************************** Timeres login a login success üzenet miatt!!
//  A login gomb lenyomása után leelenőrzi hogy van-e username és jelszó beírva és hogy létezik-e olyan user
 onSubmit() {
  if (!this.username || this.username.trim() === '') {
    this.messageClass = 'error';
    this.message = 'The username field cannot be empty!';
    return; 
  }
  if (!this.password || this.password.trim() === '') {
    this.messageClass = 'error';
    this.message = 'The password field cannot be empty!';
    return; 
  }

  this.auth.login(this.username, this.password).subscribe({
    next: () => {
      this.messageClass = 'success';
      this.message = 'Login successful!';
      setTimeout(() => {
        this.router.navigate(['/dashboard']);
      }, 600);
    },
    error: (err) => {
      this.messageClass = 'error';
      this.message = err.error?.message || 'Invalid username or password!';
    }
  });
}
}
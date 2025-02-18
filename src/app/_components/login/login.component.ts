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
  emptyUsername = '';
  emptyPassword = '';
  messageClass = '';
  inputClass = '';
  errorUsernameText = '';
  errorPasswordText = '';
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
  // Reset error messages and styles for username and password
  this.emptyUsername = '';
  this.emptyPassword = '';
  this.errorUsernameText = '';
  this.errorPasswordText = '';
  this.inputClass = '';
  this.message = '';
  this.messageClass = ''; // Reset message class at the start

  let hasError = false; // A flag to track if there are validation errors

  if (!this.username || this.username.trim() === '') {
    this.inputClass = 'inputError';
    this.errorUsernameText = 'errorUsernameText';
    this.emptyUsername = 'The username field cannot be empty!';
    hasError = true;
  }

  // Check if password is empty
  if (!this.password || this.password.trim() === '') {
    this.errorPasswordText = 'errorPasswordText';
    this.inputClass = 'inputError';
    this.emptyPassword = 'The password field cannot be empty!';
    hasError = true;
  }

  // If there are any validation errors, stop the submission
  if (hasError) {
    return;
  }

  // Call the auth service to perform login
  this.auth.login(this.username, this.password).subscribe({
    next: () => {
      this.messageClass = 'success'; // Only set messageClass to success on successful login
      this.inputClass = 'inputSuccess';
      this.message = 'Login successful!';
      setTimeout(() => {
        this.router.navigate(['/dashboard']);
      }, 600);
    },
    error: (err) => {
      // Only show error messageClass if both fields were filled but login failed
      this.messageClass = 'error'; 
      this.inputClass = 'inputError';
      this.message = err.error?.message || 'Invalid username or password!';
    }
  });
}


}
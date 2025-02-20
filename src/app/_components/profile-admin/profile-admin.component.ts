import { Component, OnInit } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Router } from '@angular/router';
import { NavbarComponent } from '../navbar/navbar.component';
import { AuthService } from '../../_services/auth.service';
import { FormBuilder, FormGroup, Validators, ReactiveFormsModule, ValidatorFn, AbstractControl } from '@angular/forms';

interface PasswordChangeRequest {
  userId: number;
  oldPassword: string;
  newPassword: string;
}

interface UsernameChangeRequest {
  userId: number;
  newUsername: string;
}

interface ErrorResponse {
  status: string;
  statusCode: number;
}

@Component({
  selector: 'app-profile-admin',
  standalone: true,
  imports: [NavbarComponent, ReactiveFormsModule],
  templateUrl: './profile-admin.component.html',
  styleUrl: './profile-admin.component.css'
})
export class ProfileAdminComponent implements OnInit {
  private userId: number;
  passwordForm: FormGroup;
  usernameForm: FormGroup;
  message: string = '';
  messageClass: string = '';

  constructor(
    private http: HttpClient,
    private authService: AuthService,
    private router: Router,
    private fb: FormBuilder
  ) {
    const storedId = localStorage.getItem('id');
    this.userId = storedId ? parseInt(storedId, 10) : 0;

    this.passwordForm = this.fb.group({
      oldPassword: ['', Validators.required],
      newPassword: ['', [
        Validators.required,
        Validators.minLength(6),
        this.passwordComplexityValidator() // Custom validator for complexity
      ]],
      newPasswordAgain: ['', Validators.required]
    }, { validators: this.passwordMatchValidator });

    this.usernameForm = this.fb.group({
      newUsername: ['', Validators.required]
    });
  }

  ngOnInit(): void {
    this.updateUserInfo();
  }

  // Custom validator for password complexity
  passwordComplexityValidator(): ValidatorFn {
    return (control: AbstractControl): { [key: string]: any } | null => {
      const value = control.value || '';
      const hasLowercase = /[a-z]/.test(value);
      const hasUppercase = /[A-Z]/.test(value);
      const hasSpecial = /[!@#$%^&*(),.?":{}|<>]/.test(value); // Adjust special characters as needed

      if (!hasLowercase || !hasUppercase || !hasSpecial) {
        return { complexity: true };
      }
      return null;
    };
  }

  passwordMatchValidator(form: FormGroup) {
    const newPassword = form.get('newPassword')?.value;
    const newPasswordAgain = form.get('newPasswordAgain')?.value;
    return newPassword === newPasswordAgain ? null : { mismatch: true };
  }

  updatePassword(): void {
    this.message = '';
    this.messageClass = '';

    if (this.passwordForm.invalid) {
      this.passwordForm.markAllAsTouched();
      return;
    }

    const { oldPassword, newPassword } = this.passwordForm.value;

    const passwordRequest: PasswordChangeRequest = {
      userId: this.userId,
      oldPassword,
      newPassword
    };

    this.http.put('http://127.0.0.1:8080/raktarproject-1.0-SNAPSHOT/webresources/user/passwordChangeByUserId', 
      passwordRequest
    ).subscribe({
      next: (response) => {
        this.message = 'Password updated successfully!';
        this.messageClass = 'success-message';
        this.passwordForm.reset();
        this.updateUserInfo();
      },
      error: (error) => {
        const errorResponse: ErrorResponse = error.error;
        if (error.status === 400 || error.status === 403) {
          this.passwordForm.get('oldPassword')?.setErrors({ serverError: 'Password does not match' });
        } else if (errorResponse && errorResponse.status) {
          switch (errorResponse.status) {
            case 'invalidNewPassword':
              this.message = 'The new password is invalid. Please ensure it meets the requirements.';
              break;
            default:
              this.message = `Error: ${errorResponse.status} (Code: ${errorResponse.statusCode})`;
          }
          this.messageClass = 'error-message';
        } else {
          this.message = 'An unexpected error occurred while updating the password.';
          this.messageClass = 'error-message';
        }
        if (error.status === 401) {
          this.authService.logout();
          this.router.navigate(['/login']);
        }
      }
    });
  }

  updateUsername(): void {
    this.message = '';
    this.messageClass = '';

    if (this.usernameForm.invalid) {
      this.usernameForm.markAllAsTouched();
      return;
    }

    const { newUsername } = this.usernameForm.value;

    const usernameRequest: UsernameChangeRequest = {
      userId: this.userId,
      newUsername
    };

    this.http.put('http://127.0.0.1:8080/raktarproject-1.0-SNAPSHOT/webresources/user/usernameChangeByUserId', 
      usernameRequest
    ).subscribe({
      next: (response) => {
        this.message = 'Username updated successfully!';
        this.messageClass = 'success-message';
        localStorage.setItem('userName', newUsername);
        (document.getElementById('userName') as HTMLElement).textContent = newUsername;
        this.usernameForm.reset();
        this.updateUserInfo();
      },
      error: (error) => {
        const errorResponse: ErrorResponse = error.error;
        if (errorResponse && errorResponse.status) {
          switch (errorResponse.status) {
            case 'invalidNewUsername':
              this.message = 'The new username is invalid or already taken.';
              break;
            default:
              this.message = `Error: ${errorResponse.status} (Code: ${errorResponse.statusCode})`;
          }
          this.messageClass = 'error-message';
        } else {
          this.message = 'An unexpected error occurred while updating the username.';
          this.messageClass = 'error-message';
        }
        if (error.status === 401) {
          this.authService.logout();
          this.router.navigate(['/login']);
        }
      }
    });
  }

  signOut(): void {
    this.authService.logout();
    this.router.navigate(['/login']);
  }

  private updateUserInfo(): void {
    (document.getElementById('userName') as HTMLElement).textContent = localStorage.getItem('userName') || 'Unknown';
    (document.getElementById('firstName') as HTMLElement).textContent = localStorage.getItem('firstName') || 'Unknown';
    (document.getElementById('lastName') as HTMLElement).textContent = localStorage.getItem('lastName') || 'Unknown';
  }
}
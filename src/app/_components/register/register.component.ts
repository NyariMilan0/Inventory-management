import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators, ReactiveFormsModule, ValidatorFn, AbstractControl } from '@angular/forms';
import { CommonModule } from '@angular/common';
import { NavbarComponent } from '../navbar/navbar.component';
import { HttpClient } from '@angular/common/http';
import { ProfileAdminComponent } from '../profile/profile-admin.component';

@Component({
  selector: 'app-register',
  standalone: true,
  imports: [NavbarComponent, CommonModule, ReactiveFormsModule, ProfileAdminComponent],
  templateUrl: './register.component.html',
  styleUrls: ['./register.component.css']
})
export class RegisterComponent implements OnInit {
  userForm!: FormGroup;
  adminForm!: FormGroup;
  userMessage: string = '';
  adminMessage: string = '';
  userMessageClass: string = '';
  adminMessageClass: string = '';

  constructor(
    private fb: FormBuilder,
    private http: HttpClient
  ) {}

  ngOnInit(): void {
    this.userForm = this.fb.group({
      userName: ['', Validators.required],
      firstName: ['', Validators.required],
      lastName: ['', Validators.required],
      email: ['', [Validators.required, Validators.email]],
      password: ['', [
        Validators.required,
        Validators.minLength(6),
        this.passwordComplexityValidator()
      ]],
      picture: ['https://www.w3schools.com/howto/img_avatar.png']
    });

    this.adminForm = this.fb.group({
      userName: ['', Validators.required], 
      firstName: ['', Validators.required],
      lastName: ['', Validators.required],
      email: ['', [Validators.required, Validators.email]],
      password: ['', [
        Validators.required,
        Validators.minLength(6),
        this.passwordComplexityValidator()
      ]],
      picture: ['https://www.w3schools.com/howto/img_avatar.png']
    });
  }

  passwordComplexityValidator(): ValidatorFn {
    return (control: AbstractControl): { [key: string]: any } | null => {
      const value = control.value || '';
      const hasLowercase = /[a-z]/.test(value);
      const hasUppercase = /[A-Z]/.test(value);
      const hasSpecial = /[!@#$%^&*(),.?":{}|<>]/.test(value);
      return (!hasLowercase || !hasUppercase || !hasSpecial) ? { complexity: true } : null;
    };
  }

  onUserSubmit(): void {
    this.userMessage = '';
    this.userMessageClass = '';

    if (this.userForm.invalid) {
      this.userForm.markAllAsTouched();
      return;
    }

    const userData = this.userForm.value;

    this.http.post('http://127.0.0.1:8080/raktarproject-1.0-SNAPSHOT/webresources/user/registerUser', userData)
      .subscribe({
        next: (response) => {
          this.userMessage = 'User registered successfully!';
          this.userMessageClass = 'success-message';
          this.userForm.reset();
        },
        error: (error) => {
          const errorResponse = error.error || {};
          this.userMessage = errorResponse.message || 'An error occurred while registering the user.';
          this.userMessageClass = 'error-message';
        }
      });
  }

  onAdminSubmit(): void {
    this.adminMessage = '';
    this.adminMessageClass = '';

    if (this.adminForm.invalid) {
      this.adminForm.markAllAsTouched();
      return;
    }

    const adminData = this.adminForm.value;

    this.http.post('http://127.0.0.1:8080/raktarproject-1.0-SNAPSHOT/webresources/user/registerAdmin', adminData)
      .subscribe({
        next: (response) => {
          this.adminMessage = 'Admin registered successfully!';
          this.adminMessageClass = 'success-message';
          this.adminForm.reset();
        },
        error: (error) => {
          const errorResponse = error.error || {};
          this.adminMessage = errorResponse.message || 'An error occurred while registering the admin.';
          this.adminMessageClass = 'error-message';
        }
      });
  }
}
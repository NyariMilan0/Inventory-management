import { Component, OnInit } from '@angular/core';
import { CommonModule, NgIf } from '@angular/common';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { AuthService } from '../../_services/auth.service';
import { delay } from 'rxjs';

@Component({
  standalone: true,
  imports: [CommonModule, NgIf, ReactiveFormsModule],
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.css']
})
export class LoginComponent implements OnInit {
  loginForm: FormGroup;
  message: string = '';
  messageClass: string = '';
  isLoading: boolean = false;
  showPassword: boolean = false;

  constructor(
    private fb: FormBuilder,
    private auth: AuthService,
    private router: Router
  ) {
    this.loginForm = this.fb.group({
      username: ['', [Validators.required]],
      password: ['', [Validators.required]],
    });
  }

  ngOnInit(): void {
  }

  onSubmit(): void {
    if (this.loginForm.valid) {
      this.isLoading = true;
      this.message = '';
      this.messageClass = '';

      const { username, password } = this.loginForm.value;
      this.auth.login(username, password).subscribe({
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
          this.isLoading = false;
        },
        complete: () => {
          this.isLoading = false;
        }
      });
    } else {
      this.loginForm.markAllAsTouched();
    }
  }

  togglePassword(): void {
    this.showPassword = !this.showPassword;
  }
}
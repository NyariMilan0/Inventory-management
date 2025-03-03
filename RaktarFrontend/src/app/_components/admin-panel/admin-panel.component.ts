import { Component, OnInit, OnDestroy, AfterViewInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators, ValidatorFn, AbstractControl } from '@angular/forms';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule } from '@angular/forms';
import { Subscription } from 'rxjs';
import { ModalService } from '../../_services/modal.service';
import { AdminPanelService, Storage, Shelf, Item, ApiResponse } from '../../_services/admin-panel.service';
import { Router, NavigationEnd } from '@angular/router';

@Component({
  selector: 'app-admin-panel',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  templateUrl: './admin-panel.component.html',
  styleUrls: ['./admin-panel.component.css']
})
export class AdminPanelComponent implements OnInit, OnDestroy, AfterViewInit {
  userForm: FormGroup;
  adminForm: FormGroup;
  itemForm: FormGroup;
  storageForm: FormGroup;
  shelfForm: FormGroup;
  deleteShelfForm: FormGroup;
  deleteStorageForm: FormGroup;
  showModal: boolean = false;
  activeTab: string = 'registerUser';
  userMessage: string = '';
  adminMessage: string = '';
  itemMessage: string = '';
  storageMessage: string = '';
  shelfMessage: string = '';
  deleteShelfMessage: string = '';
  deleteStorageMessage: string = '';
  userMessageClass: string = '';
  adminMessageClass: string = '';
  itemMessageClass: string = '';
  storageMessageClass: string = '';
  shelfMessageClass: string = '';
  deleteShelfMessageClass: string = '';
  deleteStorageMessageClass: string = '';
  storages: Storage[] = [];
  shelves: Shelf[] = [];
  private subscription: Subscription = new Subscription();
  private wasClosedByEsc: boolean = false;

  constructor(
    private fb: FormBuilder,
    private modalService: ModalService,
    private adminPanelService: AdminPanelService,
    private router: Router
  ) {
    this.userForm = this.fb.group({
      userName: ['', Validators.required],
      firstName: ['', Validators.required],
      lastName: ['', Validators.required],
      email: ['', [Validators.required, Validators.email]],
      password: ['', [Validators.required, Validators.minLength(6), this.passwordComplexityValidator()]],
      picture: ['https://www.w3schools.com/howto/img_avatar.png']
    });

    this.adminForm = this.fb.group({
      userName: ['', Validators.required],
      firstName: ['', Validators.required],
      lastName: ['', Validators.required],
      email: ['', [Validators.required, Validators.email]],
      password: ['', [Validators.required, Validators.minLength(6), this.passwordComplexityValidator()]],
      picture: ['https://www.w3schools.com/howto/img_avatar.png']
    });

    this.itemForm = this.fb.group({
      sku: ['', Validators.required],
      type: ['', Validators.required],
      name: ['', Validators.required],
      amount: ['', [Validators.required, Validators.min(1)]],
      price: ['', [Validators.required, Validators.min(1)]],
      weight: ['', [Validators.required, Validators.min(0.1)]],
      size: ['', [Validators.required, Validators.min(0.1)]],
      description: ['']
    });

    this.storageForm = this.fb.group({
      name: ['', Validators.required],
      location: ['', Validators.required]
    });

    this.shelfForm = this.fb.group({
      storageId: ['', Validators.required],
      name: ['', Validators.required],
      locationIn: ['', Validators.required]
    });

    this.deleteShelfForm = this.fb.group({
      storageId: ['', Validators.required],
      shelfId: ['', Validators.required]
    });

    this.deleteStorageForm = this.fb.group({
      storageId: ['', Validators.required]
    });
  }

  ngOnInit(): void {
    this.subscription.add(
      this.modalService.showAdminModal$.subscribe(show => {
        this.showModal = show;
        if (show) {
          this.openModal();
          this.loadTabData();
        } else {
          this.closeModal();
        }
      })
    );

    this.subscription.add(
      this.router.events.subscribe(event => {
        if (event instanceof NavigationEnd) {
          this.modalService.closeAdminModal();
          this.showModal = false;
        }
      })
    );
  }

  ngAfterViewInit(): void {
    const modalElement = document.getElementById('adminPanelModal');
    if (modalElement) {
      modalElement.addEventListener('keydown', (event) => {
        if (event.key === 'Escape') {
          this.wasClosedByEsc = true;
          this.modalService.closeAdminModal();
        }
      });
      modalElement.addEventListener('hidden.bs.modal', () => {
        if (!this.wasClosedByEsc) {
          const triggerButton = document.querySelector('.admin-panel-btn') as HTMLElement;
          if (triggerButton) {
            triggerButton.focus();
          }
        }
        this.wasClosedByEsc = false;
      });
    }
  }

  ngOnDestroy(): void {
    this.modalService.closeAdminModal();
    this.subscription.unsubscribe();
  }

  setActiveTab(tab: string): void {
    this.activeTab = tab;
    if (this.showModal) {
      this.loadTabData();
    }
  }

  openModal(): void {
    const modalElement = document.getElementById('adminPanelModal');
    if (modalElement && this.showModal) {
      const bootstrap = (window as any).bootstrap;
      if (bootstrap && bootstrap.Modal) {
        const modalInstance = bootstrap.Modal.getInstance(modalElement);
        if (!modalInstance) {
          const modal = new bootstrap.Modal(modalElement);
          modal.show();
        }
      }
    }
  }

  closeModal(): void {
    const modalElement = document.getElementById('adminPanelModal');
    if (modalElement) {
      const bootstrap = (window as any).bootstrap;
      if (bootstrap && bootstrap.Modal) {
        const modal = bootstrap.Modal.getInstance(modalElement);
        if (modal) {
          modal.hide();
        }
      }
    }
  }

  passwordComplexityValidator(): ValidatorFn {
    return (control: AbstractControl): { [key: string]: any } | null => {
      const value = control.value || '';
      if (value.length < 6) return { minlength: true };
      const hasUppercase = /[A-Z]/.test(value);
      const hasLowercase = /[a-z]/.test(value);
      const hasNumber = /\d/.test(value);
      const hasSpecial = /[!@#$%^&*(),.?":{}|<>]/.test(value);
      return (!hasUppercase || !hasLowercase || !hasNumber || !hasSpecial) ? { complexity: true } : null;
    };
  }

  getErrorMessage(control: AbstractControl | null, fieldName: string): string {
    if (!control || !control.errors || !control.touched) return '';
    const errors = control.errors;
    if (errors['required']) return `${fieldName} is required.`;
    if (errors['email']) return `${fieldName} must be a valid email address.`;
    if (errors['minlength']) return `${fieldName} must be at least 6 characters long.`;
    if (errors['min']) return `${fieldName} must be at least ${errors['min'].min}.`;
    if (errors['complexity']) return `${fieldName} must include at least one uppercase letter, one lowercase letter, one number, and one special character.`;
    return `Invalid ${fieldName.toLowerCase()}. Please check and try again!`;
  }

  fetchStorages(): void {
    this.adminPanelService.getAllStorages().subscribe({
      next: (response) => this.handleFetchResponse(response, 'storages'),
      error: (err) => console.error('Error fetching storages:', err)
    });
  }

  fetchShelvesByStorage(storageId: number): void {
    this.adminPanelService.getShelvesByStorage(storageId).subscribe({
      next: (response) => this.handleFetchResponse(response, 'shelves'),
      error: (err) => {
        if (err.status === 404) {
          this.shelves = [];
          this.deleteShelfMessage = 'No shelves found for this storage.';
          this.deleteShelfMessageClass = 'info-message';
        } else {
          console.error('Error fetching shelves:', err);
          this.deleteShelfMessage = 'Error fetching shelves.';
          this.deleteShelfMessageClass = 'error-message';
        }
      }
    });
  }

  onStorageChange(event: Event): void {
    const storageId = Number((event.target as HTMLSelectElement).value);
    if (storageId) {
      this.fetchShelvesByStorage(storageId);
    } else {
      this.shelves = [];
    }
  }

  onUserSubmit(): void {
    if (this.userForm.invalid) {
      this.userForm.markAllAsTouched();
      return;
    }
    this.userMessage = '';
    this.userMessageClass = '';
    this.adminPanelService.registerUser(this.userForm.value).subscribe({
      next: (response) => this.handleResponse(response, 'user'),
      error: (err) => {
        this.userMessage = 'Failed to register user.';
        this.userMessageClass = 'error-message';
        console.error('Error registering user:', err);
      }
    });
  }

  onAdminSubmit(): void {
    if (this.adminForm.invalid) {
      this.adminForm.markAllAsTouched();
      return;
    }
    this.adminMessage = '';
    this.adminMessageClass = '';
    this.adminPanelService.registerAdmin(this.adminForm.value).subscribe({
      next: (response) => this.handleResponse(response, 'admin'),
      error: (err) => {
        this.adminMessage = 'Failed to register admin.';
        this.adminMessageClass = 'error-message';
        console.error('Error registering admin:', err);
      }
    });
  }

  onItemSubmit(): void {
    if (this.itemForm.invalid) {
      this.itemForm.markAllAsTouched();
      return;
    }
    this.itemMessage = '';
    this.itemMessageClass = '';
    this.adminPanelService.addItem(this.itemForm.value).subscribe({
      next: (response) => this.handleResponse(response, 'item'),
      error: (err) => {
        this.itemMessage = 'Failed to add item.';
        this.itemMessageClass = 'error-message';
        console.error('Error adding item:', err);
      }
    });
  }

  onStorageSubmit(): void {
    if (this.storageForm.invalid) {
      this.storageForm.markAllAsTouched();
      return;
    }
    this.storageMessage = '';
    this.storageMessageClass = '';
    this.adminPanelService.addStorage(this.storageForm.value).subscribe({
      next: (response) => {
        this.handleResponse(response, 'storage');
        if (response.success) this.fetchStorages();
      },
      error: (err) => {
        this.storageMessage = 'Failed to add storage.';
        this.storageMessageClass = 'error-message';
        console.error('Error adding storage:', err);
      }
    });
  }

  onShelfSubmit(): void {
    if (this.shelfForm.invalid) {
      this.shelfForm.markAllAsTouched();
      return;
    }
    this.shelfMessage = '';
    this.shelfMessageClass = '';
    this.adminPanelService.addShelf(this.shelfForm.value).subscribe({
      next: (response) => this.handleResponse(response, 'shelf'),
      error: (err) => {
        this.shelfMessage = 'Failed to add shelf.';
        this.shelfMessageClass = 'error-message';
        console.error('Error adding shelf:', err);
      }
    });
  }

  onDeleteShelfSubmit(): void {
    if (this.deleteShelfForm.invalid) {
      this.deleteShelfForm.markAllAsTouched();
      return;
    }
    this.deleteShelfMessage = '';
    this.deleteShelfMessageClass = '';
    const shelfId = Number(this.deleteShelfForm.get('shelfId')?.value);
    this.adminPanelService.deleteShelf(shelfId).subscribe({
      next: (response) => {
        this.handleResponse(response, 'deleteShelf');
        if (response.success) {
          const storageId = Number(this.deleteShelfForm.get('storageId')?.value);
          this.fetchShelvesByStorage(storageId);
        }
      },
      error: (err) => {
        this.deleteShelfMessage = 'Failed to delete shelf.';
        this.deleteShelfMessageClass = 'error-message';
        console.error('Error deleting shelf:', err);
      }
    });
  }

  onDeleteStorageSubmit(): void {
    if (this.deleteStorageForm.invalid) {
      this.deleteStorageForm.markAllAsTouched();
      return;
    }
    this.deleteStorageMessage = '';
    this.deleteStorageMessageClass = '';
    const storageId = Number(this.deleteStorageForm.get('storageId')?.value);
    this.adminPanelService.deleteStorage(storageId).subscribe({
      next: (response) => {
        this.handleResponse(response, 'deleteStorage');
        if (response.success) this.fetchStorages();
      },
      error: (err) => {
        this.deleteStorageMessage = 'Failed to delete storage.';
        this.deleteStorageMessageClass = 'error-message';
        console.error('Error deleting storage:', err);
      }
    });
  }

  private handleResponse(response: ApiResponse, type: string): void {
    switch (type) {
      case 'user':
        this.userMessage = response.message;
        this.userMessageClass = response.success ? 'success-message' : 'error-message';
        if (response.success) this.userForm.reset();
        break;
      case 'admin':
        this.adminMessage = response.message;
        this.adminMessageClass = response.success ? 'success-message' : 'error-message';
        if (response.success) this.adminForm.reset();
        break;
      case 'item':
        this.itemMessage = response.message;
        this.itemMessageClass = response.success ? 'success-message' : 'error-message';
        if (response.success) this.itemForm.reset();
        break;
      case 'storage':
        this.storageMessage = response.message;
        this.storageMessageClass = response.success ? 'success-message' : 'error-message';
        if (response.success) this.storageForm.reset();
        break;
      case 'shelf':
        this.shelfMessage = response.message;
        this.shelfMessageClass = response.success ? 'success-message' : 'error-message';
        if (response.success) this.shelfForm.reset();
        break;
      case 'deleteShelf':
        this.deleteShelfMessage = response.message;
        this.deleteShelfMessageClass = response.success ? 'success-message' : 'error-message';
        if (response.success) this.deleteShelfForm.reset();
        break;
      case 'deleteStorage':
        this.deleteStorageMessage = response.message;
        this.deleteStorageMessageClass = response.success ? 'success-message' : 'error-message';
        if (response.success) this.deleteStorageForm.reset();
        break;
    }
  }

  private handleFetchResponse(response: ApiResponse, type: string): void {
    switch (type) {
      case 'storages':
        this.storages = response.data || [];
        this.shelfMessage = response.success ? '' : response.message;
        this.shelfMessageClass = response.success ? '' : 'error-message';
        this.deleteShelfMessage = response.success ? '' : response.message;
        this.deleteShelfMessageClass = response.success ? '' : 'error-message';
        this.deleteStorageMessage = response.success ? '' : response.message;
        this.deleteStorageMessageClass = response.success ? '' : 'error-message';
        if (response.success) {
          this.storages.forEach(storage => {
            this.adminPanelService.getShelvesByStorage(storage.id).subscribe({
              next: (shelfResponse) => {
                storage.hasShelves = shelfResponse.success && shelfResponse.data.length > 0;
              },
              error: (err) => {
                storage.hasShelves = false;
                console.error(`Error fetching shelves for storage ${storage.id}:`, err);
              }
            });
          });
        }
        break;
      case 'shelves':
        this.shelves = response.data || [];
        this.deleteShelfMessage = response.success ? '' : response.message;
        this.deleteShelfMessageClass = response.success ? '' : 'error-message';
        break;
    }
  }

  private loadTabData(): void {
    if (this.activeTab === 'addShelf' || this.activeTab === 'deleteShelf' || this.activeTab === 'deleteStorage') {
      this.fetchStorages();
    }
  }
}
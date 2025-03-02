import { Component, OnInit, OnDestroy, AfterViewInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators, ValidatorFn, AbstractControl } from '@angular/forms';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule } from '@angular/forms';
import { Subscription } from 'rxjs';
import { ModalService } from '../../_services/modal.service';
import { AdminPanelService, Storage, Shelf, Item, ApiResponse } from '../../_services/admin-panel.service';


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
    private adminPanelService: AdminPanelService
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
      storageName: ['', Validators.required],
      location: ['', Validators.required]
    });

    this.shelfForm = this.fb.group({
      storageId: ['', Validators.required],
      shelfName: ['', Validators.required],
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
    this.subscription = this.modalService.showAdminModal$.subscribe(show => {
      this.showModal = show;
      if (show) {
        this.openModal();
        this.loadTabData();
      } else {
        this.closeModal();
      }
    });
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
    if (modalElement) {
      const bootstrap = (window as any).bootstrap;
      if (bootstrap && bootstrap.Modal) {
        const modal = new bootstrap.Modal(modalElement);
        modal.show();
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
      if (value.length < 6) {
        return { minlength: true };
      }
      if (value.length >= 6) {
        const hasUppercase = /[A-Z]/.test(value);
        const hasLowercase = /[a-z]/.test(value);
        const hasNumber = /\d/.test(value);
        const hasSpecial = /[!@#$%^&*(),.?":{}|<>]/.test(value);
        return (!hasUppercase || !hasLowercase || !hasNumber || !hasSpecial) ? { complexity: true } : null;
      }
      return null;
    };
  }

  getErrorMessage(control: AbstractControl | null, fieldName: string): string {
    if (!control || !control.errors || !control.touched) {
      return '';
    }

    const errors = control.errors;
    if (errors['required']) {
      return `${fieldName} is required.`;
    }
    if (errors['email']) {
      return `${fieldName} must be a valid email address.`;
    }
    if (errors['minlength']) {
      return `${fieldName} must be at least 6 characters long.`;
    }
    if (errors['min']) {
      return `${fieldName} must be at least ${errors['min'].min}.`;
    }
    if (errors['complexity']) {
      return `${fieldName} must include at least one uppercase letter, one lowercase letter, one number, and one special character.`;
    }
    return `Something’s off with the ${fieldName.toLowerCase()}. Please check the input and try again!`;
  }

  fetchStorages(): void {
    this.adminPanelService.getAllStorages().subscribe({
      next: (response) => {
        this.handleFetchResponse(response, 'storages');
        if (response.success) {
          this.storages.forEach(storage => {
            this.adminPanelService.getShelvesByStorage(storage.id).subscribe({
              next: (shelfResponse) => {
                if (shelfResponse.success) {
                  storage.hasShelves = shelfResponse.data.length > 0;
                } else {
                  storage.hasShelves = false;
                }
              }
            });
          });
        }
      }
    });
  }

  fetchShelvesByStorage(storageId: number): void {
    this.adminPanelService.getShelvesByStorage(storageId).subscribe({
      next: (response) => {
        this.handleFetchResponse(response, 'shelves');
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
    this.userMessage = '';
    this.userMessageClass = '';
    if (this.userForm.invalid) {
      this.userForm.markAllAsTouched();
      return;
    }
    this.adminPanelService.registerUser(this.userForm.value).subscribe({
      next: (response) => {
        this.handleResponse(response, 'user');
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
    this.adminPanelService.registerAdmin(this.adminForm.value).subscribe({
      next: (response) => {
        this.handleResponse(response, 'admin');
      }
    });
  }

  onItemSubmit(): void {
    this.itemMessage = '';
    this.itemMessageClass = '';
    if (this.itemForm.invalid) {
      this.itemForm.markAllAsTouched();
      return;
    }
    this.adminPanelService.addItem(this.itemForm.value).subscribe({
      next: (response) => {
        this.handleResponse(response, 'item');
      }
    });
  }

  onStorageSubmit(): void {
    this.storageMessage = '';
    this.storageMessageClass = '';
    if (this.storageForm.invalid) {
      this.storageForm.markAllAsTouched();
      return;
    }
    this.adminPanelService.addStorage(this.storageForm.value).subscribe({
      next: (response) => {
        this.handleResponse(response, 'storage');
        if (response.success) {
          this.fetchStorages();
        }
      }
    });
  }

  onShelfSubmit(): void {
    this.shelfMessage = '';
    this.shelfMessageClass = '';
    if (this.shelfForm.invalid) {
      this.shelfForm.markAllAsTouched();
      return;
    }
    this.adminPanelService.addShelf(this.shelfForm.value).subscribe({
      next: (response) => {
        this.handleResponse(response, 'shelf');
      }
    });
  }

  onDeleteShelfSubmit(): void {
    this.deleteShelfMessage = '';
    this.deleteShelfMessageClass = '';
    if (this.deleteShelfForm.invalid) {
      this.deleteShelfForm.markAllAsTouched();
      return;
    }
    const shelfId = Number(this.deleteShelfForm.get('shelfId')?.value);
    this.adminPanelService.deleteShelf(shelfId).subscribe({
      next: (response) => {
        this.handleResponse(response, 'deleteShelf');
        if (response.success) {
          const storageId = Number(this.deleteShelfForm.get('storageId')?.value);
          this.fetchShelvesByStorage(storageId);
        }
      }
    });
  }

  onDeleteStorageSubmit(): void {
    this.deleteStorageMessage = '';
    this.deleteStorageMessageClass = '';
    if (this.deleteStorageForm.invalid) {
      this.deleteStorageForm.markAllAsTouched();
      return;
    }
    const storageId = Number(this.deleteStorageForm.get('storageId')?.value);
    this.adminPanelService.deleteStorage(storageId).subscribe({
      next: (response) => {
        this.handleResponse(response, 'deleteStorage');
        if (response.success) {
          this.fetchStorages();
        }
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
        this.storages = response.data;
        this.shelfMessage = response.success ? '' : response.message;
        this.shelfMessageClass = response.success ? '' : 'error-message';
        this.deleteShelfMessage = response.success ? '' : response.message;
        this.deleteShelfMessageClass = response.success ? '' : 'error-message';
        this.deleteStorageMessage = response.success ? '' : response.message;
        this.deleteStorageMessageClass = response.success ? '' : 'error-message';
        break;
      case 'shelves':
        this.shelves = response.data;
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
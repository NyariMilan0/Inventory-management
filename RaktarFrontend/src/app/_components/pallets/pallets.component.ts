import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule } from '@angular/forms';
import { PalletsService, PalletWithShelf } from '../../_services/pallets.service';
import { Shelf, Item, ApiResponse, Storage } from '../../_services/admin-panel.service';
import { NavbarComponent } from '../navbar/navbar.component';
import { AdminPanelComponent } from '../admin-panel/admin-panel.component';
import { ProfileComponent } from '../profile/profile.component';

@Component({
  selector: 'app-pallets',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, NavbarComponent, AdminPanelComponent, ProfileComponent],
  templateUrl: './pallets.component.html',
  styleUrls: ['./pallets.component.css']
})
export class PalletsComponent implements OnInit {
  activeTab: string = 'addRemove';
  addPalletForm: FormGroup;
  removePalletForm: FormGroup;
  movePalletForm: FormGroup;
  addPalletMessage: string = '';
  removePalletMessage: string = '';
  movePalletMessage: string = '';
  addPalletMessageClass: string = '';
  removePalletMessageClass: string = '';
  movePalletMessageClass: string = '';
  filteredItems: Item[] = [];
  filteredShelves: Shelf[] = [];
  filteredAvailableShelves: Shelf[] = [];
  filteredShelvesWithPallets: Shelf[] = [];
  filteredPalletsForRemoval: PalletWithShelf[] = [];
  items: Item[] = [];
  allShelves: Shelf[] = [];
  pallets: PalletWithShelf[] = [];
  storages: Storage[] = [];

  constructor(private fb: FormBuilder, private palletsService: PalletsService) {
    const userId = Number(localStorage.getItem('userId')) || 0;

    this.addPalletForm = this.fb.group({
      skuCode: ['', Validators.required],
      shelfId: ['', Validators.required],
      height: ['', [Validators.required, Validators.min(1)]]
    });

    this.removePalletForm = this.fb.group({
      shelfId: ['', Validators.required],
      palletId: ['', Validators.required]
    });

    this.movePalletForm = this.fb.group({
      sourceStorageId: ['', Validators.required],
      palletId: ['', Validators.required],
      targetStorageId: ['', Validators.required],
      targetShelfId: ['', Validators.required],
      userId: [userId >= 0 ? userId : '', Validators.required]
    });
  }

  ngOnInit(): void {
    this.loadInitialData();
  }

  loadInitialData(): void {
    this.palletsService.getAllItems().subscribe({
      next: (response: ApiResponse) => {
        if (response.success) {
          this.items = response.data.items || response.data;
          this.filteredItems = this.items;
          console.log('Items loaded:', this.items);
        } else {
          console.error('Failed to load items:', response.message);
        }
      },
      error: (err) => console.error('Error fetching items:', err)
    });

    this.palletsService.getAllShelfs().subscribe({
      next: (response: ApiResponse) => {
        if (response.success) {
          this.allShelves = response.data;
          this.filteredShelves = this.allShelves;
          this.filteredAvailableShelves = this.allShelves.filter((shelf: Shelf) => !shelf.shelfIsFull);
          this.updateShelvesWithPallets();
          console.log('Shelves loaded:', this.allShelves);
        } else {
          console.error('Failed to load shelves:', response.message);
        }
      },
      error: (err) => console.error('Error fetching shelves:', err)
    });

    this.palletsService.getAllStorages().subscribe({
      next: (response: ApiResponse) => {
        if (response.success) {
          this.storages = response.data;
          console.log('Storages loaded:', this.storages);
        } else {
          console.error('Failed to load storages:', response.message);
        }
      },
      error: (err) => console.error('Error fetching storages:', err)
    });

    this.palletsService.getPalletsWithShelfs().subscribe({
      next: (response: ApiResponse) => {
        if (response.success) {
          this.pallets = response.data.palletsAndShelfs || response.data;
          this.updateShelvesWithPallets();
          console.log('Pallets loaded:', this.pallets);
        } else {
          console.error('Failed to load pallets:', response.message);
        }
      },
      error: (err) => console.error('Error fetching pallets:', err)
    });
  }

  setActiveTab(tab: string): void {
    this.activeTab = tab;
  }

  filterItems(event: Event): void {
    const searchTerm = (event.target as HTMLInputElement).value.toLowerCase();
    this.filteredItems = this.items.filter((item: Item) =>
      item.sku.toLowerCase().includes(searchTerm) || item.name.toLowerCase().includes(searchTerm)
    );
  }

  filterShelves(event: Event): void {
    const searchTerm = (event.target as HTMLInputElement).value.toLowerCase();
    this.filteredShelves = this.allShelves.filter((shelf: Shelf) =>
      shelf.shelfName.toLowerCase().includes(searchTerm) || shelf.shelfLocation.toLowerCase().includes(searchTerm)
    );
    this.filteredAvailableShelves = this.filteredShelves.filter((shelf: Shelf) => !shelf.shelfIsFull);
    this.updateShelvesWithPallets();
  }

  updateShelvesWithPallets(): void {
    this.filteredShelvesWithPallets = this.filteredShelves.filter((shelf: Shelf) =>
      this.pallets.some((p: PalletWithShelf) => p.shelfId === shelf.shelfId)
    );
    this.updateFilteredPalletsForRemoval();
  }

  updateFilteredPalletsForRemoval(): void {
    const shelfId = Number(this.removePalletForm.get('shelfId')?.value);
    if (shelfId) {
      this.filteredPalletsForRemoval = this.pallets.filter((p: PalletWithShelf) => p.shelfId === shelfId);
    } else {
      this.filteredPalletsForRemoval = [];
    }
  }

  onAddPalletSubmit(): void {
    this.addPalletMessage = '';
    this.addPalletMessageClass = '';
    if (this.addPalletForm.invalid) {
      this.addPalletForm.markAllAsTouched();
      return;
    }
    this.palletsService.addPalletToShelf(this.addPalletForm.value).subscribe({
      next: (response: ApiResponse) => {
        this.addPalletMessage = response.message;
        this.addPalletMessageClass = response.success ? 'success-message' : 'error-message';
        if (response.success) {
          this.addPalletForm.reset();
          this.refreshShelvesAndPallets();
        }
      },
      error: (err) => {
        this.addPalletMessage = 'Error adding pallet';
        this.addPalletMessageClass = 'error-message';
        console.error('Add pallet error:', err);
      }
    });
  }

  onRemovePalletSubmit(): void {
    this.removePalletMessage = '';
    this.removePalletMessageClass = '';
    if (this.removePalletForm.invalid) {
      this.removePalletForm.markAllAsTouched();
      return;
    }
    const palletId = this.removePalletForm.get('palletId')?.value;
    this.palletsService.deletePalletById(palletId).subscribe({
      next: (response: ApiResponse) => {
        this.removePalletMessage = response.message;
        this.removePalletMessageClass = response.success ? 'success-message' : 'error-message';
        if (response.success) {
          this.removePalletForm.reset();
          this.refreshShelvesAndPallets();
        }
      },
      error: (err) => {
        this.removePalletMessage = 'Error removing pallet';
        this.removePalletMessageClass = 'error-message';
        console.error('Remove pallet error:', err);
      }
    });
  }

  onShelfChange(event: Event): void {
    const shelfId = Number((event.target as HTMLInputElement).value);
    if (shelfId) {
      this.removePalletForm.get('palletId')?.setValue('');
      this.updateFilteredPalletsForRemoval();
    }
  }

  onSourceStorageChange(event: Event): void {
    const storageId = Number((event.target as HTMLSelectElement).value);
    if (storageId) {
      this.palletsService.getShelfsByStorageId(storageId).subscribe({
        next: (response: ApiResponse) => {
          if (response.success) {
            const shelvesWithPallets = response.data.filter((shelf: Shelf) => shelf.shelfIsFull);
            this.pallets = shelvesWithPallets.flatMap((shelf: Shelf) =>
              this.pallets.filter((p: PalletWithShelf) => p.shelfId === shelf.shelfId)
            );
            console.log('Pallets updated for source storage:', this.pallets);
          } else {
            console.error('Failed to load shelves for source storage:', response.message);
          }
        },
        error: (err) => console.error('Error fetching shelves for source storage:', err)
      });
    } else {
      this.pallets = [];
    }
  }

  onTargetStorageChange(event: Event): void {
    const storageId = Number((event.target as HTMLSelectElement).value);
    if (storageId) {
      this.palletsService.getShelfsByStorageId(storageId).subscribe({
        next: (response: ApiResponse) => {
          if (response.success) {
            this.filteredAvailableShelves = response.data.filter((shelf: Shelf) => !shelf.shelfIsFull);
            console.log('Available shelves updated for target storage:', this.filteredAvailableShelves);
          } else {
            console.error('Failed to load shelves for target storage:', response.message);
          }
        },
        error: (err) => console.error('Error fetching shelves for target storage:', err)
      });
    } else {
      this.filteredAvailableShelves = [];
    }
  }

  onMovePalletSubmit(): void {
    this.movePalletMessage = '';
    this.movePalletMessageClass = '';
    if (this.movePalletForm.invalid) {
      this.movePalletForm.markAllAsTouched();
      return;
    }
    const { palletId, targetShelfId, userId } = this.movePalletForm.value;
    const fromShelfId = this.pallets.find(p => p.palletId === Number(palletId))?.shelfId;
    if (!fromShelfId) {
      this.movePalletMessage = 'Current shelf not found for this pallet.';
      this.movePalletMessageClass = 'error-message';
      console.error('Pallet not found in pallets array:', palletId, this.pallets);
      return;
    }
    this.palletsService.movePallet(palletId, fromShelfId, targetShelfId, userId).subscribe({
      next: (response: ApiResponse) => {
        this.movePalletMessage = response.message;
        this.movePalletMessageClass = response.statusCode === 200 ? 'success-message' : 'error-message';
        if (response.statusCode === 200) {
          this.movePalletForm.reset();
          const newUserId = Number(localStorage.getItem('userId')) || 0;
          this.movePalletForm.patchValue({ userId: newUserId });
          this.refreshShelvesAndPallets();
        }
      },
      error: (err) => {
        this.movePalletMessage = 'Error moving pallet';
        this.movePalletMessageClass = 'error-message';
        console.error('Move pallet error:', err);
      }
    });
  }

  refreshShelvesAndPallets(): void {
    this.palletsService.getAllShelfs().subscribe({
      next: (res: ApiResponse) => {
        if (res.success) {
          this.allShelves = res.data;
          this.filteredShelves = this.allShelves;
          this.filteredAvailableShelves = this.allShelves.filter((shelf: Shelf) => !shelf.shelfIsFull);
          this.updateShelvesWithPallets();
          console.log('Shelves refreshed:', this.allShelves);
        } else {
          console.error('Failed to refresh shelves:', res.message);
        }
      },
      error: (err) => console.error('Error refreshing shelves:', err)
    });
    this.palletsService.getPalletsWithShelfs().subscribe({
      next: (res: ApiResponse) => {
        if (res.success) {
          this.pallets = res.data.palletsAndShelfs || res.data;
          this.updateShelvesWithPallets();
          console.log('Pallets refreshed:', this.pallets);
        } else {
          console.error('Failed to refresh pallets:', res.message);
        }
      },
      error: (err) => console.error('Error refreshing pallets:', err)
    });
  }

  trackById(index: number, item: any): any {
    return item.id || item.shelfId;
  }

  trackByPalletId(index: number, item: any): any {
    return item.palletId;
  }
}
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
      targetShelfId: ['', Validators.required]
    });
  }

  ngOnInit(): void {
    this.palletsService.getAllItems().subscribe({
      next: (response: ApiResponse) => {
        if (response.success) {
          this.items = response.data;
          this.filteredItems = this.items;
        }
      }
    });
    this.palletsService.getAllShelfs().subscribe({
      next: (response: ApiResponse) => {
        if (response.success) {
          this.allShelves = response.data;
          this.filteredShelves = this.allShelves;
          this.filteredAvailableShelves = this.allShelves.filter((shelf: Shelf) => !shelf.hasPallet);
          this.updateShelvesWithPallets();
        }
      }
    });
    this.palletsService.getAllStorages().subscribe({
      next: (response: ApiResponse) => {
        if (response.success) {
          this.storages = response.data;
        }
      }
    });
    this.palletsService.getPalletsWithShelfs().subscribe({
      next: (response: ApiResponse) => {
        if (response.success) {
          this.pallets = response.data.palletsAndShelfs;
          this.updateShelvesWithPallets();
        }
      }
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
      shelf.name.toLowerCase().includes(searchTerm) || shelf.locationIn.toLowerCase().includes(searchTerm)
    );
    this.filteredAvailableShelves = this.filteredShelves.filter((shelf: Shelf) => !shelf.hasPallet);
    this.updateShelvesWithPallets();
  }

  updateShelvesWithPallets(): void {
    this.filteredShelvesWithPallets = this.filteredShelves.filter((shelf: Shelf) =>
      this.pallets.some((p: PalletWithShelf) => p.shelfId === shelf.id)
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
      this.palletsService.getShelvesByStorage(storageId).subscribe({
        next: (response: ApiResponse) => {
          if (response.success) {
            const shelvesWithPallets = response.data.filter((shelf: Shelf) => shelf.hasPallet);
            this.pallets = shelvesWithPallets.flatMap((shelf: Shelf) =>
              this.pallets.filter((p: PalletWithShelf) => p.shelfId === shelf.id)
            );
          }
        }
      });
    } else {
      this.pallets = [];
    }
  }

  onTargetStorageChange(event: Event): void {
    const storageId = Number((event.target as HTMLSelectElement).value);
    if (storageId) {
      this.palletsService.getShelvesByStorage(storageId).subscribe({
        next: (response: ApiResponse) => {
          if (response.success) {
            this.filteredAvailableShelves = response.data.filter((shelf: Shelf) => !shelf.hasPallet);
          }
        }
      });
    } else {
      this.filteredAvailableShelves = [];
    }
  }

  refreshShelvesAndPallets(): void {

    this.palletsService.getAllShelfs().subscribe({
      next: (res: ApiResponse) => {
        if (res.success) {
          this.allShelves = res.data;
          this.filteredShelves = this.allShelves;
          this.filteredAvailableShelves = this.allShelves.filter((shelf: Shelf) => !shelf.hasPallet);
          this.updateShelvesWithPallets();
        }
      }
    });
    this.palletsService.getPalletsWithShelfs().subscribe({
      next: (res: ApiResponse) => {
        if (res.success) {
          this.pallets = res.data.palletsAndShelfs;
          this.updateShelvesWithPallets();
        }
      }
    });
  }

  trackById(index: number, item: any): any {
    return item.id;
  }

  trackByPalletId(index: number, item: any): any {
    return item.palletId;
  }
}

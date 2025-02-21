// src/app/_components/item-list/item-list.component.ts
import { Component, OnInit, ViewChild, ElementRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { NavbarComponent } from '../navbar/navbar.component';

export interface Item {
  id: number;
  sku: string;
  material: string;
  name: string;
  quantity: number;
  price: number;
  weight: number;
  dimensions: number;
  description: string;
  imageUrl?: string; // Optional property for image URL
}

@Component({
  selector: 'app-item-list',
  standalone: true,
  imports: [CommonModule, NavbarComponent],
  templateUrl: './item-list.component.html',
  styleUrls: ['./item-list.component.css']
})
export class ItemListComponent implements OnInit {
  originalItems: Item[] = []; // Store the original list of items
  items: Item[] = []; // The filtered/displayed list of items
  selectedItem: Item | null = null; // Track the selected item for the modal
  selectedCategories: string[] = []; // Track selected categories for filtering
  isWeightAscending: boolean = true; // Track weight sort direction
  isNameAscending: boolean = true; // Track name sort direction

  @ViewChild('itemModal', { static: false }) modalElement!: ElementRef; // Reference to the item modal

  constructor() {}

  ngOnInit(): void {
    // Initialize items with the original list
    this.originalItems = [
      { id: 21, sku: 'asd', material: 'Wood', name: 'asd', quantity: 1, price: 1, weight: 1, dimensions: 1, description: 'asd', imageUrl: 'assets/images/placeholder.png' },
      { id: 22, sku: 'SKU002', material: 'Wood', name: 'Wooden Chair', quantity: 25, price: 79.99, weight: 5.5, dimensions: 45, description: 'Comfortable wooden chair with cushioned seat.', imageUrl: 'assets/images/placeholder.png' },
      { id: 23, sku: 'SKU003', material: 'Wood', name: 'Bookshelf', quantity: 15, price: 149.99, weight: 20, dimensions: 180, description: 'Large wooden bookshelf with 5 shelves.', imageUrl: 'assets/images/placeholder.png' },
      { id: 24, sku: 'SKU004', material: 'Wood', name: 'Coffee Table', quantity: 20, price: 89.99, weight: 10, dimensions: 90, description: 'Stylish wooden coffee table for living rooms.', imageUrl: 'assets/images/placeholder.png' },
      { id: 25, sku: 'SKU005', material: 'Wood', name: 'Wooden Bed Frame', quantity: 8, price: 299.99, weight: 30, dimensions: 200, description: 'Durable king-size wooden bed frame.', imageUrl: 'assets/images/placeholder.png' },
      { id: 26, sku: 'SKU006', material: 'Metal', name: 'Metal Cabinet', quantity: 12, price: 249.99, weight: 25, dimensions: 160, description: 'Secure metal storage cabinet with lock.', imageUrl: 'assets/images/placeholder.png' },
      { id: 27, sku: 'SKU007', material: 'Metal', name: 'Steel Chair', quantity: 30, price: 59.99, weight: 6, dimensions: 50, description: 'Modern steel chair with ergonomic design.', imageUrl: 'assets/images/placeholder.png' },
      { id: 28, sku: 'SKU008', material: 'Metal', name: 'Metal Shelf', quantity: 18, price: 199.99, weight: 18, dimensions: 150, description: 'Heavy-duty metal shelf for storage.', imageUrl: 'assets/images/placeholder.png' },
      { id: 29, sku: 'SKU009', material: 'Metal', name: 'Iron Table', quantity: 10, price: 179.99, weight: 20, dimensions: 110, description: 'Industrial-style iron dining table.', imageUrl: 'assets/images/placeholder.png' },
      { id: 30, sku: 'SKU010', material: 'Metal', name: 'Metal Bed Frame', quantity: 7, price: 279.99, weight: 28, dimensions: 190, description: 'Strong and sturdy metal bed frame.', imageUrl: 'assets/images/placeholder.png' },
      { id: 31, sku: 'SKU011', material: 'Plastic', name: 'Plastic Chair', quantity: 40, price: 29.99, weight: 2.5, dimensions: 45, description: 'Lightweight and durable plastic chair.', imageUrl: 'assets/images/placeholder.png' },
      { id: 32, sku: 'SKU012', material: 'Plastic', name: 'Plastic Storage Box', quantity: 50, price: 19.99, weight: 3, dimensions: 40, description: 'Transparent plastic storage box with lid.', imageUrl: 'assets/images/placeholder.png' },
      { id: 33, sku: 'SKU013', material: 'Plastic', name: 'Kids Toy Set', quantity: 60, price: 24.99, weight: 1.2, dimensions: 30, description: 'Colorful plastic toy set for children.', imageUrl: 'assets/images/placeholder.png' },
      { id: 34, sku: 'SKU014', material: 'Plastic', name: 'Plastic Table', quantity: 22, price: 69.99, weight: 5, dimensions: 80, description: 'Easy-to-clean plastic table for outdoor use.', imageUrl: 'assets/images/placeholder.png' },
      { id: 35, sku: 'SKU015', material: 'Plastic', name: 'Water Bottle', quantity: 100, price: 9.99, weight: 0.8, dimensions: 25, description: 'Reusable BPA-free plastic water bottle.', imageUrl: 'assets/images/placeholder.png' },
      { id: 36, sku: 'SKU016', material: 'Aluminum', name: 'Aluminum Ladder', quantity: 15, price: 129.99, weight: 10.5, dimensions: 150, description: 'Lightweight and durable aluminum ladder.', imageUrl: 'assets/images/placeholder.png' },
      { id: 37, sku: 'SKU017', material: 'Aluminum', name: 'Aluminum Suitcase', quantity: 20, price: 199.99, weight: 8, dimensions: 70, description: 'Scratch-resistant aluminum travel suitcase.', imageUrl: 'assets/images/placeholder.png' },
      { id: 38, sku: 'SKU018', material: 'Aluminum', name: 'Aluminum Laptop Stand', quantity: 30, price: 39.99, weight: 1.5, dimensions: 35, description: 'Ergonomic aluminum stand for laptops.', imageUrl: 'assets/images/placeholder.png' },
      { id: 39, sku: 'SKU019', material: 'Aluminum', name: 'Aluminum Bicycle', quantity: 10, price: 499.99, weight: 12, dimensions: 160, description: 'Lightweight aluminum frame mountain bike.', imageUrl: 'assets/images/placeholder.png' },
      { id: 40, sku: 'SKU020', material: 'Aluminum', name: 'Aluminum Frying Pan', quantity: 25, price: 59.99, weight: 2, dimensions: 30, description: 'Non-stick aluminum frying pan for cooking.', imageUrl: 'assets/images/placeholder.png' }
    ];
    this.items = [...this.originalItems]; // Initialize displayed items with the original list
  }

  openModal(item: Item): void {
    this.selectedItem = item;
    if (this.modalElement) {
      const bootstrapModal = new (window as any).bootstrap.Modal(this.modalElement.nativeElement);
      bootstrapModal.show();
    } else {
      console.error('Modal element not found');
    }
  }

  toggleCategory(category: string): void {
    const index = this.selectedCategories.indexOf(category);
    if (index === -1) {
      this.selectedCategories.push(category);
    } else {
      this.selectedCategories.splice(index, 1);
    }
    this.filterItems();
  }

  filterItems(): void {
    if (this.selectedCategories.length === 0) {
      // If no categories are selected, restore the original list
      this.items = [...this.originalItems];
    } else {
      // Filter items to show those matching any selected category (OR logic)
      this.items = this.originalItems.filter(item => 
        this.selectedCategories.some(category => item.material === category)
      );
    }
  }

  sortByWeight(): void {
    this.items.sort((a, b) => {
      return this.isWeightAscending ? a.weight - b.weight : b.weight - a.weight;
    });
    this.isWeightAscending = !this.isWeightAscending; // Toggle direction
  }

  sortByName(): void {
    this.items.sort((a, b) => {
      return this.isNameAscending ? a.name.localeCompare(b.name) : b.name.localeCompare(a.name);
    });
    this.isNameAscending = !this.isNameAscending; // Toggle direction
  }
}
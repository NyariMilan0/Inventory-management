import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';

interface Section {
  name: string;
  date: string;
  freePlaces: number;
  usedPlaces: number;
  usagePercentage: number;
}

interface Category {
  name: string;
  item: string;
  stockPercentage: number;
  lowStock: boolean;
}

interface Warehouse {
  name: string;
  sections: Section[];
  totalFree: number;
  totalUsed: number;
  overallCapacity: number;
}

@Component({
  standalone: true,
  selector: 'app-warehouse-storage',
  templateUrl: './storage-management.component.html',
  styleUrls: ['./storage-management.component.css'],
  imports: [CommonModule]
})
export class StorageManagementComponent {
  warehouses: Warehouse[] = [
    {
      name: 'Section 01',
      sections: [{ name: 'Section 01', date: '2023/04/06', freePlaces: 25, usedPlaces: 15, usagePercentage: 37.5 }],
      totalFree: 25,
      totalUsed: 15,
      overallCapacity: 37.5
    },
    {
      name: 'Section 02',
      sections: [{ name: 'Section 02', date: '2023/04/06', freePlaces: 15, usedPlaces: 25, usagePercentage: 62.5 }],
      totalFree: 15,
      totalUsed: 25,
      overallCapacity: 62.5
    },
    {
      name: 'Section 03',
      sections: [{ name: 'Section 03', date: '2023/04/06', freePlaces: 15, usedPlaces: 25, usagePercentage: 62.5 }],
      totalFree: 15,
      totalUsed: 25,
      overallCapacity: 62.5
    },
    {
      name: 'Section 04',
      sections: [{ name: 'Section 04', date: '2023/04/06', freePlaces: 15, usedPlaces: 25, usagePercentage: 62.5 }],
      totalFree: 15,
      totalUsed: 25,
      overallCapacity: 62.5
    },
    {
      name: 'Section 05',
      sections: [{ name: 'Section 05', date: '2023/04/06', freePlaces: 15, usedPlaces: 25, usagePercentage: 62.5 }],
      totalFree: 15,
      totalUsed: 25,
      overallCapacity: 62.5
    },
    {
      name: 'Section 06',
      sections: [{ name: 'Section 06', date: '2023/04/06', freePlaces: 4, usedPlaces: 36, usagePercentage: 90 }],
      totalFree: 4,
      totalUsed: 36,
      overallCapacity: 90
    }
  ];

  categories: Category[] = [
    { name: 'Category 01', item: 'item A', stockPercentage: 10, lowStock: true },
    { name: 'Category 02', item: 'item B', stockPercentage: 10, lowStock: true },
    { name: 'Category 03', item: 'item C', stockPercentage: 15, lowStock: true },
    { name: 'Category 04', item: 'item D', stockPercentage: 10, lowStock: true },
  ];

  getShelves(free: number, used: number) {
    const total = free + used;
    const shelves = [];
    for (let i = 0; i < total; i++) {
      shelves.push({ used: i < used });
    }
    return shelves;
  }

  getSpinnerBackground(capacity: number): string {
    return `conic-gradient(#003366 ${capacity}%, #f0f8ff 0%)`;
  }
}
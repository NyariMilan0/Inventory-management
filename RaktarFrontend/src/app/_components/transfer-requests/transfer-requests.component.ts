import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { NavbarComponent } from '../navbar/navbar.component';

interface TransferItem {
  pallet: string;
  location: string;
  targetLocation: string;
  actionType: string;
  timeLimit: string;
  status: string;
}

@Component({
  selector: 'app-transfer-requests',
  standalone: true,
  imports: [CommonModule, NavbarComponent],
  templateUrl: './transfer-requests.component.html',
  styleUrls: ['./transfer-requests.component.css']
})
export class TransferRequestsComponent {
  sortDirection: string = 'newest';
  sortDirectionLabel: string = 'Newest';
  transferData: TransferItem[] = [
    { pallet: 'Pallet 4', location: 'Shelf 5', targetLocation: 'Shelf 11', actionType: 'Move', timeLimit: '2025-01-31 13:23:44', status: 'Completed' },
    { pallet: 'Pallet 8', location: 'Shelf 10', targetLocation: 'Shelf 2', actionType: 'Update', timeLimit: '2025-01-31 13:23:44', status: 'Failed' },
    { pallet: 'Pallet 15', location: 'Shelf 23', targetLocation: 'Shelf 7', actionType: 'Add', timeLimit: '2025-01-31 13:23:44', status: 'Completed' },
    { pallet: 'Pallet 6', location: 'Shelf 3', targetLocation: 'Shelf 15', actionType: 'Add', timeLimit: '2025-01-31 13:23:44', status: 'Pending' },
    { pallet: 'Pallet 11', location: 'Shelf 1', targetLocation: 'Shelf 21', actionType: 'Update', timeLimit: '2025-01-31 13:23:44', status: 'Pending' },
    { pallet: 'Pallet 5', location: 'Shelf 17', targetLocation: 'Shelf 4', actionType: 'Remove', timeLimit: '2025-01-31 13:23:44', status: 'Failed' },
    { pallet: 'Pallet 13', location: 'Shelf 6', targetLocation: 'Shelf 18', actionType: 'Move', timeLimit: '2025-01-31 13:23:44', status: 'Completed' },
    { pallet: 'Pallet 17', location: 'Shelf 8', targetLocation: 'Shelf 9', actionType: 'Remove', timeLimit: '2025-01-31 13:23:44', status: 'Pending' },
    { pallet: 'Pallet 17', location: 'Shelf 8', targetLocation: 'Shelf 9', actionType: 'Remove', timeLimit: '2025-01-31 13:23:44', status: 'Pending' },
    { pallet: 'Pallet 17', location: 'Shelf 8', targetLocation: 'Shelf 9', actionType: 'Remove', timeLimit: '2025-01-31 13:23:44', status: 'Pending' },
    { pallet: 'Pallet 17', location: 'Shelf 8', targetLocation: 'Shelf 9', actionType: 'Remove', timeLimit: '2025-01-31 13:23:44', status: 'Pending' },
    { pallet: 'Pallet 17', location: 'Shelf 8', targetLocation: 'Shelf 9', actionType: 'Remove', timeLimit: '2025-01-31 13:23:44', status: 'Pending' }
  ];
  filteredData: TransferItem[] = [...this.transferData];

  sortTable() {
    this.sortDirection = this.sortDirection === 'newest' ? 'oldest' : 'newest';
    this.sortDirectionLabel = this.sortDirection.charAt(0).toUpperCase() + this.sortDirection.slice(1);
    this.filteredData.sort((a, b) => {
      const timeA = new Date(a.timeLimit);
      const timeB = new Date(b.timeLimit);
      return this.sortDirection === 'newest' ? timeB.getTime() - timeA.getTime() : timeA.getTime() - timeB.getTime();
    });
  }

  search(event: Event) {
    const query = (event.target as HTMLInputElement).value.trim().toLowerCase();
    if (!query) {
      this.filteredData = [...this.transferData];
      return;
    }
    this.filteredData = this.transferData.filter(item =>
      item.pallet.toLowerCase().includes(query) ||
      item.location.toLowerCase().includes(query) ||
      item.targetLocation.toLowerCase().includes(query) ||
      item.actionType.toLowerCase().includes(query) ||
      item.status.toLowerCase().includes(query)
    );
  }
}
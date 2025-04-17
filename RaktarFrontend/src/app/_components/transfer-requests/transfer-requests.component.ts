import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { NavbarComponent } from '../navbar/navbar.component';
import { AdminPanelComponent } from '../admin-panel/admin-panel.component';
import { ProfileComponent } from '../profile/profile.component';

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
  imports: [CommonModule, NavbarComponent, AdminPanelComponent, ProfileComponent],
  templateUrl: './transfer-requests.component.html',
  styleUrls: ['./transfer-requests.component.css']
})
export class TransferRequestsComponent implements OnInit {
  sortDirection: string = 'newest';
  sortDirectionLabel: string = 'Newest';
  transferData: TransferItem[] = [
    { pallet: 'Pallet 4', location: 'Shelf 5', targetLocation: 'Shelf 11', actionType: 'Move', timeLimit: '2025-04-17 13:23:44', status: 'Pending' },
    { pallet: 'Pallet 8', location: 'Shelf 10', targetLocation: 'Shelf 2', actionType: 'Update', timeLimit: '2025-04-16 16:30:00', status: 'Pending' },
    { pallet: 'Pallet 15', location: 'Shelf 23', targetLocation: 'Shelf 7', actionType: 'Add', timeLimit: '2025-04-17 16:30:00', status: 'Pending' },
    { pallet: 'Pallet 6', location: 'Shelf 3', targetLocation: 'Shelf 15', actionType: 'Add', timeLimit: '2025-04-15 16:30:00', status: 'Pending' },
    { pallet: 'Pallet 11', location: 'Shelf 1', targetLocation: 'Shelf 21', actionType: 'Update', timeLimit: '2025-04-16 16:30:00', status: 'Pending' },
    { pallet: 'Pallet 5', location: 'Shelf 17', targetLocation: 'Shelf 4', actionType: 'Remove', timeLimit: '2025-05-15 16:30:00', status: 'Pending' },
    { pallet: 'Pallet 13', location: 'Shelf 6', targetLocation: 'Shelf 18', actionType: 'Move', timeLimit: '2025-04-30 16:30:00', status: 'Pending' },
    { pallet: 'Pallet 17', location: 'Shelf 8', targetLocation: 'Shelf 9', actionType: 'Remove', timeLimit: '2025-04-20 16:30:00', status: 'Pending' }
  ];
  filteredData: TransferItem[] = [...this.transferData];

  ngOnInit() {
    this.updateExpiredStatuses();
    setInterval(() => this.updateExpiredStatuses(), 60000); // Percenként frissiti hogy a task nem-e járt még le
  }

  updateExpiredStatuses() {
    const now = new Date();
    this.transferData = this.transferData.map(item => {
      if (item.status === 'Pending') {
        const timeLimit = new Date(item.timeLimit);
        if (now > timeLimit) {
          return { ...item, status: 'Failed' };
        }
      }
      return item;
    });
    this.filteredData = [...this.transferData];
  }

  confirmComplete(item: TransferItem) {
    const confirmed = confirm(`Are you sure you want to mark "${item.pallet}" as Completed?`);
    if (confirmed) {
      this.completeTransfer(item);
    }
  }

  completeTransfer(item: TransferItem) {
    const index = this.transferData.findIndex(t => t.pallet === item.pallet && t.timeLimit === item.timeLimit);
    if (index !== -1) {
      this.transferData[index].status = 'Completed';
      this.filteredData = [...this.transferData];
    }
  }

  sortTable() {
    this.sortDirection = this.sortDirection === ' Newest' ? ' Oldest' : ' Newest';
    this.sortDirectionLabel = this.sortDirection.charAt(0).toUpperCase() + this.sortDirection.slice(1);
    this.filteredData.sort((a, b) => {
      const timeA = new Date(a.timeLimit);
      const timeB = new Date(b.timeLimit);
      return this.sortDirection === ' Newest' ? timeB.getTime() - timeA.getTime() : timeA.getTime() - timeB.getTime();
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
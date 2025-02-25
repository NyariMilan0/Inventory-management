import { Injectable } from '@angular/core';
import { BehaviorSubject } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class ModalService {
  private showProfileModalSource = new BehaviorSubject<boolean>(false);
  showProfileModal$ = this.showProfileModalSource.asObservable();

  openProfileModal() {
    this.showProfileModalSource.next(true);
  }

  closeProfileModal() {
    this.showProfileModalSource.next(false);
  }
}
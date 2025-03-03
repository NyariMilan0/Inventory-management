import { Injectable } from '@angular/core';
import { HttpClient, HttpErrorResponse } from '@angular/common/http';
import { Observable, of } from 'rxjs';
import { catchError, map } from 'rxjs/operators';
import { Storage, Shelf, Item, ApiResponse } from '../_services/admin-panel.service';

export interface PalletWithShelf {
  shelfId: number;
  shelfLocation: string;
  palletId: number;
  palletName: string;
  shelfName: string;
}

@Injectable({ providedIn: 'root' })
export class PalletsService {
  private baseUrl = 'http://127.0.0.1:8080/raktarproject-1.0-SNAPSHOT/webresources';

  constructor(private http: HttpClient) {}

  getAllItems(): Observable<ApiResponse> {
    return this.http.get<any>(`${this.baseUrl}/items/getItemList`).pipe(
      map(response => {
        if (response && Array.isArray(response.items)) {
          return { success: true, message: 'Items loaded successfully', data: { items: response.items } };
        } else if (Array.isArray(response)) {
          return { success: true, message: 'Items loaded successfully', data: { items: response } };
        }
        return { success: false, message: 'Invalid items data', data: [] };
      }),
      catchError(this.handleHttpError('fetching items', []))
    );
  }

  getAllShelfs(): Observable<ApiResponse> {
    return this.http.get<any>(`${this.baseUrl}/shelfs/getAllShelfs`).pipe(
      map(response => {
        if (response && Array.isArray(response.shelfs)) {
          return {
            success: response.statusCode === 200,
            message: 'Shelves loaded successfully',
            data: response.shelfs.map((shelf: any) => ({
              id: shelf.id,
              name: shelf.name,
              locationInStorage: shelf.locationInStorage,
              isFull: shelf.isFull,
              maxCapacity: shelf.maxCapacity,
              currentCapacity: shelf.currentCapacity,
              length: shelf.length,
              width: shelf.width,
              levels: shelf.levels,
              height: shelf.height
            })),
            statusCode: response.statusCode
          };
        }
        return { success: false, message: 'Invalid shelves data', data: [] };
      }),
      catchError(this.handleHttpError('fetching all shelves', []))
    );
  }

  getAllStorages(): Observable<ApiResponse> {
    return this.http.get<{ Storages: Storage[] }>(`${this.baseUrl}/storage/getAllStorages`).pipe(
      map(response => {
        if (response && Array.isArray(response.Storages)) {
          return {
            success: true,
            message: 'Storages loaded successfully',
            data: response.Storages.map(storage => ({
              ...storage,
              hasShelves: false
            }))
          };
        }
        return { success: false, message: 'Invalid storages data', data: [] };
      }),
      catchError(this.handleHttpError('fetching storages', []))
    );
  }

  addPalletToShelf(palletData: any): Observable<ApiResponse> {
    return this.http.post(`${this.baseUrl}/pallet/addPalletToShelf`, palletData).pipe(
      map(() => ({ success: true, message: 'Pallet added successfully!' })),
      catchError(this.handleHttpError('adding pallet to shelf'))
    );
  }

  getPalletsWithShelfs(): Observable<ApiResponse> {
    return this.http.get<any>(`${this.baseUrl}/shelfs/getPalletsWithShelfs`).pipe(
      map(response => {
        if (response && Array.isArray(response.palletsAndShelfs)) {
          return { success: true, message: 'Pallets with shelves loaded successfully', data: { palletsAndShelfs: response.palletsAndShelfs } };
        } else if (Array.isArray(response)) {
          return { success: true, message: 'Pallets with shelves loaded successfully', data: { palletsAndShelfs: response } };
        }
        return { success: false, message: 'Invalid pallets data', data: [] };
      }),
      catchError(this.handleHttpError('fetching pallets with shelves', []))
    );
  }

  deletePalletById(palletId: number): Observable<ApiResponse> {
    return this.http.delete(`${this.baseUrl}/pallet/deletePalletById?id=${palletId}`).pipe(
      map(() => ({ success: true, message: 'Pallet deleted successfully!' })),
      catchError(this.handleHttpError('deleting pallet'))
    );
  }

  getShelfsByStorageId(storageId: number): Observable<ApiResponse> {
    return this.http.get<any>(`${this.baseUrl}/shelfs/getShelfsByStorageId?storageId=${storageId}`).pipe(
      map(response => {
        if (response && Array.isArray(response.shelves)) {
          return {
            success: response.statusCode === 200,
            message: 'Shelves loaded successfully',
            data: response.shelves.map((shelf: any) => ({
              id: shelf.shelfId,
              name: shelf.shelfName,
              locationInStorage: shelf.shelfLocation,
              isFull: shelf.shelfIsFull,
              maxCapacity: shelf.shelfMaxCapacity
            })),
            statusCode: response.statusCode
          };
        }
        return { success: false, message: 'Invalid shelves data', data: [], statusCode: response.statusCode || 500 };
      }),
      catchError(this.handleHttpError('fetching shelves by storage id', []))
    );
  }

  movePallet(palletId: number, fromShelfId: number, toShelfId: number, userId: number): Observable<ApiResponse> {
    const moveData = { palletId, fromShelfId, toShelfId, userId };
    return this.http.post<any>(`${this.baseUrl}/pallet/movePalletBetweenShelfs`, moveData).pipe(
      map(response => ({
        success: response.statusCode === 200,
        message: response.message,
        data: null,
        statusCode: response.statusCode
      })),
      catchError(this.handleHttpError('moving pallet'))
    );
  }

  private handleHttpError(operation: string, defaultData: any = []): (error: HttpErrorResponse) => Observable<ApiResponse> {
    return (error: HttpErrorResponse) => {
      let message = `An error occurred while ${operation}.`;
      if (error.error && error.error.message) {
        message = error.error.message;
      } else {
        switch (error.status) {
          case 400:
            message = `Bad request while ${operation}. Please check your input.`;
            break;
          case 404:
            message = `Resource not found while ${operation}.`;
            break;
          case 500:
            message = `Server error while ${operation}. Please try again later.`;
            break;
          default:
            message = `Unexpected error while ${operation}. (${error.status})`;
        }
      }
      console.error(`Error ${operation}:`, error);
      return of({ success: false, message, data: defaultData, statusCode: error.status });
    };
  }
}
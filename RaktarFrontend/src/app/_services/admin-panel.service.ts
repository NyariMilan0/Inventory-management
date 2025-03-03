import { Injectable } from '@angular/core';
import { HttpClient, HttpErrorResponse } from '@angular/common/http';
import { Observable, of } from 'rxjs';
import { catchError, map } from 'rxjs/operators';

export interface Storage {
  id: number;
  name: string;
  location: string;
  currentCapacity?: number;
  maxCapacity?: number;
  isFull?: boolean;
  hasShelves?: boolean;
}

export interface Shelf {
  id: number;
  shelfId: number;          
  shelfName: string;      
  shelfLocation: string;    
  shelfIsFull: boolean;      
  shelfMaxCapacity: number;  
  currentCapacity?: number;  
  length?: number;           
  width?: number;            
  levels?: number;          
  height?: number;
}

export interface Item {
  id: number;
  sku: string;
  name: string;
  material: string;
  quantity: number;
  price: number;
  weight: number;
  dimensions: number;
  description: string;
}

export interface ApiResponse {
  success: boolean;
  message: string;
  data?: any;
  totalShelves?: number; 
  shelves?: Shelf[]; 
  statusCode?: number; 
}

@Injectable({ providedIn: 'root' })
export class AdminPanelService {
  private baseUrl = 'http://127.0.0.1:8080/raktarproject-1.0-SNAPSHOT/webresources';

  constructor(private http: HttpClient) {}

  registerUser(userData: any): Observable<ApiResponse> {
    return this.http.post(`${this.baseUrl}/user/registerUser`, userData).pipe(
      map(() => ({ success: true, message: 'User registered successfully!' })),
      catchError(this.handleHttpError('registering user'))
    );
  }

  registerAdmin(adminData: any): Observable<ApiResponse> {
    return this.http.post(`${this.baseUrl}/user/registerAdmin`, adminData).pipe(
      map(() => ({ success: true, message: 'Admin registered successfully!' })),
      catchError(this.handleHttpError('registering admin'))
    );
  }

  addItem(itemData: any): Observable<ApiResponse> {
    return this.http.post(`${this.baseUrl}/items/addItem`, itemData).pipe(
      map(() => ({ success: true, message: 'Item added successfully!' })),
      catchError(this.handleHttpError('adding item'))
    );
  }

  addStorage(storageData: any): Observable<ApiResponse> {
    return this.http.post(`${this.baseUrl}/storage/addStorage`, storageData).pipe(
      map(() => ({ success: true, message: 'Storage added successfully!' })),
      catchError(this.handleHttpError('adding storage'))
    );
  }

  addShelf(shelfData: any): Observable<ApiResponse> {
    return this.http.post(`${this.baseUrl}/shelfs/addShelfToStorage`, shelfData).pipe(
      map(() => ({ success: true, message: 'Shelf added successfully!' })),
      catchError(this.handleHttpError('adding shelf'))
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

  getShelvesByStorage(storageId: number): Observable<ApiResponse> {
    return this.http.get<any>(`${this.baseUrl}/shelfs/getShelfsByStorageId?storageId=${storageId}`).pipe(
      map(response => {
        if (response && Array.isArray(response.shelves)) {
          return {
            success: true,
            message: 'Shelves loaded successfully',
            data: response.shelves.map((shelf: any) => ({
              shelfId: shelf.shelfId,
              shelfLocation: shelf.shelfLocation,
              shelfIsFull: shelf.shelfIsFull,
              shelfName: shelf.shelfName,
              shelfMaxCapacity: shelf.shelfMaxCapacity
            }))
          };
        }
        return { success: false, message: 'Invalid shelves data', data: [] };
      }),
      catchError(this.handleHttpError('fetching shelves', []))
    );
  }

  getAllShelfs(): Observable<ApiResponse> {
    return this.http.get<Shelf[]>(`${this.baseUrl}/shelfs/getAllShelfs`).pipe(
      map(response => {
        if (Array.isArray(response)) {
          return { success: true, message: 'Shelves loaded successfully', data: response };
        }
        return { success: false, message: 'Invalid shelves data', data: [] };
      }),
      catchError(this.handleHttpError('fetching all shelves', []))
    );
  }

  getAllItems(): Observable<ApiResponse> {
    return this.http.get<Item[]>(`${this.baseUrl}/items/getItemList`).pipe(
      map(response => {
        if (Array.isArray(response)) {
          return { success: true, message: 'Items loaded successfully', data: response };
        }
        return { success: false, message: 'Invalid items data', data: [] };
      }),
      catchError(this.handleHttpError('fetching items', []))
    );
  }

  deleteShelf(shelfId: number): Observable<ApiResponse> {
    return this.http.delete(`${this.baseUrl}/shelfs/deleteShelfFromStorage?id=${shelfId}`).pipe(
      map(() => ({ success: true, message: 'Shelf deleted successfully!' })),
      catchError(this.handleHttpError('deleting shelf'))
    );
  }

  deleteStorage(storageId: number): Observable<ApiResponse> {
    return this.http.delete(`${this.baseUrl}/storage/deleteStorageById?id=${storageId}`).pipe(
      map(() => ({ success: true, message: 'Storage deleted successfully!' })),
      catchError(this.handleHttpError('deleting storage'))
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
      return of({ success: false, message, data: defaultData });
    };
  }
}
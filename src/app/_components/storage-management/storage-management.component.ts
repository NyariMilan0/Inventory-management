import { Component, ViewChild, ElementRef, AfterViewInit, OnDestroy } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FontAwesomeModule } from '@fortawesome/angular-fontawesome'; // Import FontAwesomeModule
import { NavbarComponent } from '../navbar/navbar.component';
import { ProfileAdminComponent } from '../profile-admin/profile-admin.component';

@Component({
  selector: 'app-storage-management',
  standalone: true,
  imports: [CommonModule, FontAwesomeModule, NavbarComponent, ProfileAdminComponent], // Add FontAwesomeModule
  templateUrl: './storage-management.component.html',
  styleUrls: ['./storage-management.component.css']
})
export class StorageManagementComponent implements AfterViewInit, OnDestroy {
  sections = [
    { name: 'Section 01', free: 25, used: 15, date: '', usage: 62.5, critical: false },
    { name: 'Section 02', free: 15, used: 15, date: '2023/04/06', usage: 62.5, critical: false },
    { name: 'Section 03', free: 15, used: 15, date: '2023/04/06', usage: 62.5, critical: false },
    { name: 'Section 04', free: 15, used: 15, date: '2023/04/06', usage: 62.5, critical: false },
    { name: 'Section 05', free: 15, used: 15, date: '2023/04/06', usage: 62.5, critical: false },
    { name: 'Section 06', free: 5, used: 25, date: '2023/04/06', usage: 90, critical: true },
  ];

  lowStockItems = [
    { category: 'Category 01', name: 'Item 01', stock: 10 },
    { category: 'Category 02', name: 'Item 02', stock: 10 },
    { category: 'Category 03', name: 'Item 03', stock: 10 },
    { category: 'Category 04', name: 'Item 04', stock: 10 },
    { category: 'Category 05', name: 'Item 05', stock: 8 },
    { category: 'Category 06', name: 'Item 06', stock: 7 },
    { category: 'Category 07', name: 'Item 07', stock: 5 },
    { category: 'Category 08', name: 'Item 08', stock: 12 },
    { category: 'Category 09', name: 'Item 09', stock: 9 },
    { category: 'Category 10', name: 'Item 10', stock: 6 },
  ];

  storageCapacity = 62.5;
  selectedSection = this.sections[0];
  filteredSections = [...this.sections];

  @ViewChild('carouselItems') carouselItems!: ElementRef;
  @ViewChild('carouselContainer') carouselContainer!: ElementRef;
  @ViewChild('searchInput') searchInput!: ElementRef;

  private isDragging = false;
  private startY = 0;
  private startTranslate = 0;
  private animationFrameId: number | null = null;

  ngAfterViewInit() {
    this.setupDragging();
    this.duplicateItemsForInfiniteScroll();
    this.setupSearch();
  }

  ngOnDestroy() {
    if (this.animationFrameId) {
      cancelAnimationFrame(this.animationFrameId);
    }
    this.removeEventListeners();
  }

  selectSection(section: any) {
    this.selectedSection = section;
  }

  getSectionSpaces() {
    const section = this.selectedSection;
    const totalSpaces = section.used + section.free;
    const gridSize = 12;
    const totalGridSquares = 96;
    const grids = [];
  
    const usedPercentage = section.used / totalSpaces;
    const totalUsedSquares = Math.round(usedPercentage * totalGridSquares);
    let remainingUsed = totalUsedSquares;
    let remainingFree = totalGridSquares - totalUsedSquares;
  
    for (let i = 0; i < 8; i++) {
      const grid = [];
      const usedInThisGrid = Math.min(remainingUsed, gridSize);
      const freeInThisGrid = gridSize - usedInThisGrid;
  
      for (let j = 0; j < gridSize; j++) {
        if (j < usedInThisGrid) {
          grid.push({ used: true });
          remainingUsed--;
        } else {
          grid.push({ used: false });
          remainingFree--;
        }
      }
      grids.push(grid);
    }
    return grids;
  }

  private duplicateItemsForInfiniteScroll() {
    const items = this.carouselItems.nativeElement.children as HTMLCollectionOf<HTMLElement>;
    const clone = Array.from(items, (item: HTMLElement) => item.cloneNode(true) as HTMLElement);
    clone.forEach((clonedItem: HTMLElement) => this.carouselItems.nativeElement.appendChild(clonedItem));
  }

  private setupDragging() {
    const carousel = this.carouselItems.nativeElement as HTMLElement;
    const container = this.carouselContainer.nativeElement as HTMLElement;

    const onMouseDown = (e: MouseEvent) => {
      e.preventDefault();
      this.isDragging = true;
      this.startY = e.pageY;
      this.startTranslate = this.getTranslateY();
      carousel.classList.add('dragging');
      if (this.animationFrameId) {
        cancelAnimationFrame(this.animationFrameId);
      }
    };

    const onMouseMove = (e: MouseEvent) => {
      if (!this.isDragging) return;
      const deltaY = e.pageY - this.startY;
      const newTranslate = this.startTranslate + deltaY;
      carousel.style.transform = `translateY(${newTranslate}px)`;
      this.checkBoundaries();
    };

    const onMouseUp = () => {
      if (this.isDragging) {
        this.isDragging = false;
        carousel.classList.remove('dragging');
        this.checkBoundaries();
        this.startAutoScroll();
      }
    };

    const onMouseLeave = () => {
      if (this.isDragging) {
        this.isDragging = false;
        carousel.classList.remove('dragging');
        this.checkBoundaries();
        this.startAutoScroll();
      }
    };

    container.addEventListener('mousedown', onMouseDown);
    document.addEventListener('mousemove', onMouseMove);
    document.addEventListener('mouseup', onMouseUp);
    container.addEventListener('mouseleave', onMouseLeave);

    this.eventListeners = { onMouseDown, onMouseMove, onMouseUp, onMouseLeave };
    this.startAutoScroll();
  }

  private eventListeners: any = {};

  private removeEventListeners() {
    const container = this.carouselContainer.nativeElement as HTMLElement;
    container.removeEventListener('mousedown', this.eventListeners.onMouseDown);
    document.removeEventListener('mousemove', this.eventListeners.onMouseMove);
    document.removeEventListener('mouseup', this.eventListeners.onMouseUp);
    container.removeEventListener('mouseleave', this.eventListeners.onMouseLeave);
  }

  private getTranslateY(): number {
    const style = window.getComputedStyle(this.carouselItems.nativeElement);
    const transform = style.transform || style.webkitTransform;
    if (transform === 'none') return 0;
    const matrix = transform.match(/matrix.*\((.+)\)/);
    return matrix ? parseFloat(matrix[1].split(', ')[5]) : 0;
  }

  private checkBoundaries() {
    const carousel = this.carouselItems.nativeElement as HTMLElement;
    const containerHeight = this.carouselContainer.nativeElement.offsetHeight;
    const contentHeight = carousel.offsetHeight / 2;
    let translateY = this.getTranslateY();

    if (translateY > 0) {
      translateY = -contentHeight;
    } else if (translateY < -contentHeight) {
      translateY = 0;
    }

    carousel.style.transform = `translateY(${translateY}px)`;
  }

  private startAutoScroll() {
    const carousel = this.carouselItems.nativeElement as HTMLElement;
    const containerHeight = this.carouselContainer.nativeElement.offsetHeight;
    const contentHeight = carousel.offsetHeight / 2;
    const speed = 0.4;

    const scroll = () => {
      if (this.isDragging) return;

      let translateY = this.getTranslateY();
      translateY -= speed;

      if (translateY < -contentHeight) {
        translateY = 0;
      }

      carousel.style.transform = `translateY(${translateY}px)`;
      this.animationFrameId = requestAnimationFrame(scroll);
    };

    this.animationFrameId = requestAnimationFrame(scroll);
  }

  private setupSearch() {
    const input = this.searchInput.nativeElement as HTMLInputElement;
    input.addEventListener('input', () => {
      const searchTerm = input.value.trim().toLowerCase();
      this.filteredSections = this.sections.filter(section =>
        section.name.toLowerCase().includes(searchTerm)
      );
      if (this.filteredSections.length === 0 || !this.filteredSections.includes(this.selectedSection)) {
        this.selectedSection = this.filteredSections[0] || this.sections[0];
      }
    });
  }
}
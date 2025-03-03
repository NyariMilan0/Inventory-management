import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ItemsTransferComponent } from './items-transfer.component';

describe('ItemsTransferComponent', () => {
  let component: ItemsTransferComponent;
  let fixture: ComponentFixture<ItemsTransferComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [ItemsTransferComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(ItemsTransferComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});

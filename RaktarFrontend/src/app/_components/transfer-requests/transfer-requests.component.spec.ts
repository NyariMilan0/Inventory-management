import { ComponentFixture, TestBed } from '@angular/core/testing';

import { TransferRequestsComponent } from './transfer-requests.component';

describe('TransferRequestsComponent', () => {
  let component: TransferRequestsComponent;
  let fixture: ComponentFixture<TransferRequestsComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [TransferRequestsComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(TransferRequestsComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});

import { RouterModule, Routes } from '@angular/router';
import { LoginComponent } from './_components/login/login.component';
import { StorageManagementComponent } from './_components/storage-management/storage-management.component';
import { authGuard } from './auth.guard';
import { NavbarComponent } from './_components/navbar/navbar.component';
import { ProfileAdminComponent } from './_components/profile-admin/profile-admin.component';
import { NgModule } from '@angular/core';
import { RegisterComponent } from './_components/register/register.component';
import { ItemListComponent } from './_components/item-list/item-list.component';

export const routes: Routes = [
  { path: 'login', component: LoginComponent },
  { path: 'storage', component: StorageManagementComponent},
  { path: 'register', component: RegisterComponent,canActivate: [authGuard] },
  // { path: 'pallet-management', component: PalletManagementComponent },
  { path: 'items', component: ItemListComponent },
  // { path: 'manage-items', component: ManageItemsComponent },
    {path: 'navbar', component: NavbarComponent,canActivate: [authGuard]},
    {path: 'profileAdmin', component: ProfileAdminComponent},
    { 
      path: 'dashboard', 
      component: StorageManagementComponent,
      canActivate: [authGuard]
    },
    { path: '**', redirectTo: 'login' }
    
];
@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }

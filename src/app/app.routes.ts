import { RouterModule, Routes } from '@angular/router';
import { LoginComponent } from './_components/login/login.component';
import { StorageManagementComponent } from './_components/storage-management/storage-management.component';
import { authGuard } from './auth.guard';
import { NavbarComponent } from './_components/navbar/navbar.component';
import { ProfileAdminComponent } from './_components/profile-admin/profile-admin.component';
import { ProfileUserComponent } from './_components/profile-user/profile-user.component';
import { NgModule } from '@angular/core';

export const routes: Routes = [
  { path: 'login', component: LoginComponent },
  { path: 'storage', component: StorageManagementComponent,canActivate: [authGuard] },
  // { path: 'pallet-management', component: PalletManagementComponent },
  // { path: 'items', component: ItemsComponent },
  // { path: 'manage-items', component: ManageItemsComponent },
    {path: 'navbar', component: NavbarComponent,canActivate: [authGuard]},
    {path: 'profileAdmin', component: ProfileAdminComponent,canActivate: [authGuard]},
    {path: 'profileUser', component: ProfileUserComponent,canActivate: [authGuard]},
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

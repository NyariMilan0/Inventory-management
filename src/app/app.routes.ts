import { RouterModule, Routes } from '@angular/router';
import { LoginComponent } from './_components/login/login.component';
import { StorageManagementComponent } from './_components/storage-management/storage-management.component';
import { authGuard } from './auth.guard';
import { NavbarComponent } from './_components/navbar/navbar.component';
import { ProfileAdminComponent } from './_components/profile/profile-admin.component';
import { NgModule } from '@angular/core';
import { RegisterComponent } from './_components/register/register.component';
import { ItemListComponent } from './_components/item-list/item-list.component';
import { AdminPanelComponent } from './_components/admin-panel/admin-panel.component';
import { PalletsComponent } from './_components/pallets/pallets.component';

export const routes: Routes = [
  { path: 'login', component: LoginComponent },
  { path: 'storage', component: StorageManagementComponent, canActivate: [authGuard]},
  { path: 'register', component: RegisterComponent,canActivate: [authGuard] },
  { path: 'pallets', component: PalletsComponent, canActivate: [authGuard]},
  { path: 'items', component: ItemListComponent, canActivate: [authGuard] },
  {path: 'navbar', component: NavbarComponent,canActivate: [authGuard]},
  {path: 'profileAdmin', component: ProfileAdminComponent, canActivate: [authGuard]},
  {path: 'adminPanel', component: AdminPanelComponent, canActivate: [authGuard]},
  { path: '**', redirectTo: 'login' }
    
];
@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }

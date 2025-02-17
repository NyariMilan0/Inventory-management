import { Routes } from '@angular/router';
import { LoginComponent } from './_components/login/login.component';
import { StorageManagementComponent } from './_components/storage-management/storage-management.component';
import { authGuard } from './auth.guard';
import { NavbarComponent } from './_components/navbar/navbar.component';
import { ProfileAdminComponent } from './_components/profile-admin/profile-admin.component';

export const routes: Routes = [
    { path: 'login', component: LoginComponent },
    {path: 'navbar', component: NavbarComponent},
    {path: 'profileAdmin', component: ProfileAdminComponent},
    { 
      path: 'dashboard', 
      component: StorageManagementComponent,
      canActivate: [authGuard]
    },
    { path: '**', redirectTo: 'login' }
];

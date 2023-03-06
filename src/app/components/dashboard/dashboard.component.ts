import { Component, OnInit } from '@angular/core';
import { AuthService } from '../../shared/services/auth.service';
import { Observable, Subject } from 'rxjs';
import { MatDialog } from '@angular/material/dialog';
import { UserService } from 'src/app/shared/services/user.service';
import { FormComponent } from './form/form.component';
import {
  doc,
  updateDoc,
} from '@firebase/firestore';

@Component({
  selector: 'app-dashboard',
  templateUrl: './dashboard.component.html',
  styleUrls: ['./dashboard.component.scss'],
})

export class DashboardComponent implements OnInit {
  allUsers$: Observable<any[]>;
  selectedUser?: any;
  destroyed$ = new Subject<void>();


  constructor(public authService: AuthService, private readonly dialog: MatDialog, private userService: UserService) {}

  ngOnInit(): void {
    console.log(this.authService.getEquipo().equipo)
    this.allUsers$ = this.userService.getAll(this.authService.getEquipo().equipo);
    this.allUsers$.subscribe((data) => console.log(data))
  }

  selectUser(user: any) {
    this.selectedUser = user;
  }

  addUser() {
    this.dialog.open(FormComponent, {
      data: {},
      width: '40%',
    });
  }

  deleteUser() {
    this.userService.delete(this.selectedUser!.id);
    this.selectedUser= undefined;
  }

  ngOnDestroy() {
    this.destroyed$.next();
  }
}

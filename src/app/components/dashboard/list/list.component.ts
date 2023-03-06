import { Component, Input, OnInit, Output, EventEmitter } from '@angular/core';
import { Observable } from 'rxjs';

@Component({
  selector: 'app-list',
  templateUrl: './list.component.html',
  styleUrls: ['./list.component.scss']
})
export class ListComponent implements OnInit {
  @Input() allUsers$: Observable<any>;
  @Output() userEmitter = new EventEmitter<any>();
  constructor() { }

  ngOnInit(): void {
  }

  selectUser(user: any) {
    console.log(user)
    this.userEmitter.emit(user);
  }

}

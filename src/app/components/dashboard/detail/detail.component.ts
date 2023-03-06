import { Component, Input, OnInit, Output, EventEmitter } from '@angular/core';

@Component({
  selector: 'app-detail',
  templateUrl: './detail.component.html',
  styleUrls: ['./detail.component.scss']
})
export class DetailComponent implements OnInit {
  @Input() user: any;
  @Output() deleteUser = new EventEmitter<void>();

  constructor() { }

  ngOnInit(): void {
  }

  delete() {
    this.deleteUser.emit();
  }

}

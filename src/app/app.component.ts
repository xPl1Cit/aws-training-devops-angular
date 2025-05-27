import { Component } from '@angular/core';
import { GreetingService } from './service/greeting.service';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent {
  title = 'Fetching Database...';

  constructor(private greetingService: GreetingService) {}

  ngOnInit() {
    this.greetingService.getGreeting('Jesse').subscribe({
      next: (response) => (this.title = response),
      error: (err) => console.error('Error fetching greeting', err),
    });
  }
}

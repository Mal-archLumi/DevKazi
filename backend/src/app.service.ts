import { Injectable } from '@nestjs/common';

@Injectable()
export class AppService {
  // This service can be used for app-level business logic
  // Currently kept minimal as most logic is in feature modules
  
  getWelcome() {
    return {
      message: 'Welcome to DevKazi API',
      version: '1.0.0',
      description: 'Minimal team collaboration platform',
      timestamp: new Date().toISOString()
    };
  }
}
import { Controller, Get } from '@nestjs/common';
import { InjectConnection } from '@nestjs/mongoose';
import { Connection } from 'mongoose';

@Controller()
export class AppController {
  getHello(): any {
    throw new Error('Method not implemented.');
  }
  constructor(@InjectConnection() private readonly connection: Connection) {}

  @Get('health')
  getHealth() {
    const dbStatus = this.connection.readyState === 1 ? 'connected' : 'disconnected';
    return { 
      status: 'OK', 
      message: 'DevKazi Backend is running!',
      database: dbStatus,
      timestamp: new Date().toISOString()
    };
  }

  @Get('test-db')
  async testDb() {
    try {
      // Simple database operation - count users
      const usersCount = await this.connection.collection('users').countDocuments();
      
      return { 
        database: 'MongoDB Atlas', 
        status: 'connected', 
        usersCount: usersCount,
        collections: this.connection.db ? (await this.connection.db.listCollections().toArray()).map(c => c.name) : []
      };
    } catch (error) {
      return { 
        database: 'MongoDB Atlas', 
        status: 'error', 
        error: error.message 
      };
    }
  }
}
import { Controller, Get } from '@nestjs/common';
import { InjectConnection } from '@nestjs/mongoose';
import { Connection } from 'mongoose';

@Controller()
export class AppController {
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
      // Test database operation
      if (!this.connection.db) {
        throw new Error('Database connection not established');
      }
      const adminDb = this.connection.db.admin();
      const result = await adminDb.ping();
      return { 
        database: 'MongoDB', 
        status: 'connected', 
        ping: result 
      };
    } catch (error) {
      return { 
        database: 'MongoDB', 
        status: 'error', 
        error: error.message 
      };
    }
  }
}
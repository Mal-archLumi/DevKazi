import { Controller, Get } from '@nestjs/common';
import { InjectConnection } from '@nestjs/mongoose';
import { Connection } from 'mongoose';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';

@ApiTags('App')
@Controller()
export class AppController {
  constructor(@InjectConnection() private readonly connection: Connection) {}

  @Get('health')
  @ApiOperation({ summary: 'Health check' })
  @ApiResponse({ status: 200, description: 'Service health status' })
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
  @ApiOperation({ summary: 'Test database connection' })
  @ApiResponse({ status: 200, description: 'Database connection test' })
  async testDb() {
    try {
      // Simple database operation
      const usersCount = await this.connection.collection('users').countDocuments();
      
      return { 
        database: 'MongoDB', 
        status: 'connected', 
        usersCount: usersCount,
        timestamp: new Date().toISOString()
      };
    } catch (error) {
      return { 
        database: 'MongoDB', 
        status: 'error', 
        error: error.message,
        timestamp: new Date().toISOString()
      };
    }
  }
}
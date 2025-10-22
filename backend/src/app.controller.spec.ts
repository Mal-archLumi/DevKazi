import { Test, TestingModule } from '@nestjs/testing';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { describe, it, expect, beforeEach } from '@jest/globals';



describe('AppController', () => {
  let appController: AppController;

  beforeEach(async () => {
    const app: TestingModule = await Test.createTestingModule({
      controllers: [AppController],
      providers: [AppService],
    }).compile();

    appController = app.get<AppController>(AppController);
  });

  describe('health check', () => {
    it('should return health status', () => {
      const result = appController.getHealth();
      expect(result.status).toBe('OK');
      expect(result.message).toContain('DevKazi Backend is running');
    });
  });
  });

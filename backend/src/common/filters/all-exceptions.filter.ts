import { ExceptionFilter, Catch, ArgumentsHost, HttpException, HttpStatus, Logger } from '@nestjs/common';
import { Response } from 'express';

@Catch()
export class AllExceptionsFilter implements ExceptionFilter {
  private readonly logger = new Logger(AllExceptionsFilter.name);

  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest<Request>();

    // Determine status code and message
    const status = exception instanceof HttpException
      ? exception.getStatus()
      : HttpStatus.INTERNAL_SERVER_ERROR;

    const message = exception instanceof HttpException
      ? exception.getResponse()
      : { message: 'Internal server error' };

    // Log the error for debugging (avoid logging sensitive data in production)
    this.logger.error(
      `Error occurred: ${JSON.stringify({
        path: request.url,
        status,
        message,
      })}`,
      exception instanceof Error ? exception.stack : '',
    );

    // Send standardized response
    response.status(status).json({
      statusCode: status,
      message: typeof message === 'string' ? message : (message as any).message || 'An error occurred',
      timestamp: new Date().toISOString(),
      path: request.url,
    });
  }
}
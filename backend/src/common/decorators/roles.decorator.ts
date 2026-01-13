// common/decorators/roles.decorator.ts
import { SetMetadata } from '@nestjs/common';
import { UserRole } from '../../modules/users/schemas/user.schema';

export const ROLES_KEY = 'roles';
export const Roles = (...roles: UserRole[]) => SetMetadata(ROLES_KEY, roles);

export const ADMIN_KEY = 'admin';
export const AdminOnly = () => SetMetadata(ADMIN_KEY, true);
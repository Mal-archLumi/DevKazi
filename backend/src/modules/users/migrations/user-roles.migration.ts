import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { User, UserDocument } from '../schemas/user.schema';
import { Role } from '../../../auth/enums/role.enum';

@Injectable()
export class UserRolesMigration {
  constructor(
    @InjectModel(User.name) private userModel: Model<UserDocument>,
  ) {}

  async migrateRoles(): Promise<void> {
    console.log('Starting user roles migration...');
    
    const users = await this.userModel.find().exec();
    
    for (const user of users) {
      // If user already has a roles array with data, skip
      if (user.roles && user.roles.length > 0) continue;
      
      // If user has old single role field, migrate to array
      // Note: Your current schema uses roles as string[], so we need to handle this properly
      const userObj = user.toObject();
      
      // Check if there's any existing role data to migrate
      if ((userObj as any).role) {
        // Migrate from single role field to roles array
        user.roles = [(userObj as any).role];
      } else {
        // Default to student if no roles exist
        user.roles = [Role.STUDENT];
      }
      
      await user.save();
      console.log(`Migrated user ${user.email} to roles: ${user.roles.join(', ')}`);
    }
    
    console.log('User roles migration completed!');
  }
}
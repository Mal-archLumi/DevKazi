import { Model } from 'mongoose';
import { UserDocument } from '../schemas/user.schema';
export declare class UserRolesMigration {
    private userModel;
    constructor(userModel: Model<UserDocument>);
    migrateRoles(): Promise<void>;
}

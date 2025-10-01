import { Model } from 'mongoose';
import { User, UserDocument } from './schemas/user.schema';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { UserResponseDto, PublicUserResponseDto } from './dto/user-response.dto';
import { SearchUsersDto } from './dto/search-users.dto';
export declare class UsersService {
    private userModel;
    constructor(userModel: Model<UserDocument>);
    findByEmail(email: string): Promise<UserDocument | null>;
    findById(id: string): Promise<UserDocument | null>;
    create(userData: Partial<User>): Promise<UserDocument>;
    update(id: string, updateData: Partial<User>): Promise<UserDocument | null>;
    getProfile(userId: string): Promise<UserResponseDto>;
    getPublicProfile(userId: string): Promise<PublicUserResponseDto>;
    updateProfile(userId: string, updateData: UpdateProfileDto): Promise<UserResponseDto>;
    deleteAccount(userId: string): Promise<void>;
    addSkills(userId: string, skills: string[]): Promise<UserResponseDto>;
    removeSkills(userId: string, skills: string[]): Promise<UserResponseDto>;
    searchUsers(searchDto: SearchUsersDto): Promise<{
        users: PublicUserResponseDto[];
        total: number;
    }>;
    getMentors(): Promise<PublicUserResponseDto[]>;
    getStudents(): Promise<PublicUserResponseDto[]>;
    requestVerification(userId: string): Promise<{
        message: string;
    }>;
    private validateSkills;
    private mapToUserResponseDto;
    private mapToPublicUserResponseDto;
}

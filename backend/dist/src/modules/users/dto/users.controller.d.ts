import { UsersService } from '../users.service';
import { UpdateProfileDto } from './update-profile.dto';
import { SearchUsersDto } from './search-users.dto';
import { AddSkillsDto, RemoveSkillsDto } from './skills.dto';
import { UserResponseDto, PublicUserResponseDto } from './user-response.dto';
export declare class UsersController {
    private readonly usersService;
    constructor(usersService: UsersService);
    getProfile(user: any): Promise<UserResponseDto>;
    updateProfile(user: any, updateProfileDto: UpdateProfileDto): Promise<UserResponseDto>;
    deleteAccount(user: any): Promise<{
        message: string;
    }>;
    getPublicProfile(id: string): Promise<PublicUserResponseDto>;
    addSkills(user: any, addSkillsDto: AddSkillsDto): Promise<UserResponseDto>;
    removeSkills(user: any, removeSkillsDto: RemoveSkillsDto): Promise<UserResponseDto>;
    searchUsers(searchDto: SearchUsersDto): Promise<{
        users: PublicUserResponseDto[];
        total: number;
    }>;
    getMentors(): Promise<PublicUserResponseDto[]>;
    getStudents(): Promise<PublicUserResponseDto[]>;
    requestVerification(user: any): Promise<{
        message: string;
    }>;
}

import { UsersService } from './users.service';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { SearchUsersDto } from './dto/search-users.dto';
import { AddSkillsDto, RemoveSkillsDto } from './dto/skills.dto';
import { UserResponseDto, PublicUserResponseDto } from './dto/user-response.dto';
export declare class UsersController {
    private readonly usersService;
    constructor(usersService: UsersService);
    getCurrentUser(req: any): Promise<any>;
    getProfile(req: any): Promise<UserResponseDto>;
    updateProfile(req: any, updateProfileDto: UpdateProfileDto): Promise<UserResponseDto>;
    deleteAccount(req: any): Promise<{
        message: string;
    }>;
    getUser(id: string): Promise<any>;
    getPublicProfile(id: string): Promise<PublicUserResponseDto>;
    addSkills(req: any, addSkillsDto: AddSkillsDto): Promise<UserResponseDto>;
    removeSkills(req: any, removeSkillsDto: RemoveSkillsDto): Promise<UserResponseDto>;
    searchUsers(searchDto: SearchUsersDto): Promise<{
        users: PublicUserResponseDto[];
        total: number;
    }>;
    getMentors(): Promise<PublicUserResponseDto[]>;
    getStudents(): Promise<PublicUserResponseDto[]>;
    requestVerification(req: any): Promise<{
        message: string;
    }>;
}

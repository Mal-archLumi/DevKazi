import { UsersService } from './users.service';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { AddSkillsDto, RemoveSkillsDto } from './dto/skills.dto';
import { UserResponseDto, PublicUserResponseDto } from './dto/user-response.dto';
export declare class UsersController {
    private readonly usersService;
    constructor(usersService: UsersService);
    getProfile(user: any): Promise<UserResponseDto>;
    updateProfile(user: any, updateProfileDto: UpdateProfileDto): Promise<UserResponseDto>;
    deleteAccount(user: any): Promise<{
        message: string;
    }>;
    getPublicProfile(id: string): Promise<PublicUserResponseDto>;
    updateSkills(user: any, addSkillsDto: AddSkillsDto): Promise<UserResponseDto>;
    removeSkills(user: any, removeSkillsDto: RemoveSkillsDto): Promise<UserResponseDto>;
}

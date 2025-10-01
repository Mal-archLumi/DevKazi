import { Role } from '../../../auth/enums/role.enum';
export declare class UpdateProfileDto {
    name?: string;
    email?: string;
    bio?: string;
    education?: string;
    skills?: string[];
    company?: string;
    position?: string;
    github?: string;
    linkedin?: string;
    portfolio?: string;
    experienceYears?: number;
    isProfilePublic?: boolean;
    role?: Role;
}

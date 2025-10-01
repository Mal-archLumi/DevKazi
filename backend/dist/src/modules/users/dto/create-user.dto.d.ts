import { Role } from '../../../auth/enums/role.enum';
export declare class CreateUserDto {
    email: string;
    name: string;
    password: string;
    role: Role;
    bio?: string;
    education?: string;
    skills?: string[];
}

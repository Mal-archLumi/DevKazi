import { Role } from '../../../auth/enums/role.enum';
export declare class SearchUsersDto {
    query?: string;
    role?: Role;
    skills?: string[];
    verifiedOnly?: boolean;
    page: number;
    limit: number;
}

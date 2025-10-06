import { CreateTeamDto } from './create-team.dto';
import { TeamStatus } from '../../teams/schemas/team.schema';
declare const UpdateTeamDto_base: import("@nestjs/mapped-types").MappedType<Partial<CreateTeamDto>>;
export declare class UpdateTeamDto extends UpdateTeamDto_base {
    status?: TeamStatus;
    members?: Array<{
        user: string;
        role: string;
    }>;
}
export {};

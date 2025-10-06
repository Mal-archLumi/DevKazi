export declare class CreateTeamDto {
    name: string;
    description?: string;
    projectIdea?: string;
    requiredSkills?: string[];
    preferredSkills?: string[];
    maxMembers?: number;
    isPublic?: boolean;
    allowJoinRequests?: boolean;
    requireApproval?: boolean;
    tags?: string[];
    githubRepo?: string;
    projectDemoUrl?: string;
}

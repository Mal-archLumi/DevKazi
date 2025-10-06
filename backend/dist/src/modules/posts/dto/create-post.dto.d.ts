export declare class CreatePostDto {
    title: string;
    description: string;
    requirements: string[];
    skillsRequired: string[];
    category: string;
    team?: string;
    applicationDeadline: Date;
    duration: string;
    commitment: string;
    location: string;
    stipend?: number;
    positions: number;
    tags?: string[];
    isPublic?: boolean;
}

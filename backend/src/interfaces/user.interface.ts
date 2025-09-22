export interface IUser {
  _id?: string;
  email: string;
  password: string;
  name: string;
  skills: string[];
  bio?: string;
  education?: string;
  avatar?: string;
  roles: string[];
  isVerified: boolean;
  createdAt: Date;
  updatedAt: Date;
}

export type UserDocument = IUser & Document;
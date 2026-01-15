# Devkazi - Collaborative Project Management for IT Students

**A mobile-first platform that enables Kenyan IT students to form small teams, manage software projects, communicate in real-time, and build industry-relevant collaboration skills.**


## Overview

Devkazi is a cross-platform mobile application built to bridge the gap between academic training and real-world software development practices. It provides IT students with a structured environment to:

- Form small development teams (recommended size: 4 members)
- Create and manage software projects from start to finish
- Break projects into tasks and phases
- Assign roles and responsibilities
- Track progress with visual timelines
- Communicate instantly via integrated team chat

The platform was specifically designed with the Kenyan university context in mind, where many students rely primarily on mobile devices and have limited access to paid tools or traditional internships.

## Key Features

- **User Authentication**  
  Secure registration and login with email & password (JWT-based)

- **Team Management**  
  - Create teams with name & description  
  - Invite members using unique team codes  
  - View team members and their assigned roles  
  - Leave or manage team membership

- **Project Management**  
  - Create projects with title, description & timeline  
  - Create, edit and delete tasks  
  - Assign tasks to team members  
  - Track task status (To Do → In Progress → Completed)  
  - Visual progress overview & deadlines

- **Real-time Team Chat**  
  - Dedicated chat channel per team  
  - Instant messaging with timestamps & sender names  
  - Built with WebSockets for smooth real-time experience

- **Role-based Collaboration**  
  Common roles: Frontend, Backend, QA/Testing, UI/UX, Project Manager, etc.

- **Cross-platform Mobile Experience**  
  Single codebase for Android and iOS using Flutter

## Technology Stack

| Layer            | Technology                  | Purpose                              |
|------------------|-----------------------------|--------------------------------------|
| **Frontend**     | Flutter (Dart)              | Cross-platform mobile UI             |
| **State Management** | Provider                 | Efficient app state handling         |
| **HTTP Client**  | Dio                         | API requests with interceptors       |
| **Backend**      | NestJS (TypeScript)         | RESTful API & business logic         |
| **Real-time**    | Socket.io                   | Team chat functionality              |
| **Authentication**| JWT                        | Secure token-based auth              |
| **Database**     | MongoDB + Mongoose          | Flexible document storage            |
| **Hosting**      | Render                      | Backend & API deployment             |
| **Version Control** | Git + GitHub             | Source code management               |
| **API Testing**  | Postman                     | Endpoint testing during development  |
| **IDE**          | Visual Studio Code          | Primary development environment      |

## Project Structure (simplified)

devkazi/
├── backend/                    # NestJS API
│   ├── src/
│   │   ├── auth/
│   │   ├── teams/
│   │   ├── projects/
│   │   ├── tasks/
│   │   ├── chat/
│   │   ├── users/
│   │   └── common/             # shared utilities, dtos, etc.
│   └── ...
├── mobile/                     # Flutter application
│   ├── lib/
│   │   ├── core/               # shared utilities, constants
│   │   ├── features/
│   │   │   ├── auth/
│   │   │   ├── teams/
│   │   │   ├── projects/
│   │   │   ├── tasks/
│   │   │   └── chat/
│   │   ├── models/
│   │   ├── services/
│   │   ├── providers/
│   │   └── widgets/
│   └── ...
└── documentation/


## Prerequisites

- Flutter SDK (latest stable)
- Node.js ≥ 18
- MongoDB (local or cloud)
- Git

## Getting Started

### 1. Backend Setup

# Clone the repository
git clone https://github.com/yourusername/devkazi.git
cd devkazi/backend

# Install dependencies
npm install

# Create .env file (see .env.example)
cp .env.example .env
# Edit .env with your MongoDB connection string and JWT secret

# Development
npm run start:prod

2. Mobile App Setup
   cd ../mobile

# Install dependencies
flutter pub get

# Run on connected device/emulator
flutter run

Contributing
Contributions are welcome! If you would like to help improve Devkazi:

Fork the repository
Create a feature branch (git checkout -b feature/amazing-feature)
Commit your changes (git commit -m 'Add some amazing feature')
Push to the branch (git push origin feature/amazing-feature)
Open a Pull Request

License
This project is licensed under the MIT License – see the LICENSE file for details.

👨‍💻 Author
Makutu Alvine Lumiti – BSc IT Student, Mount Kenya University
📧 Email: makutualvine@gmail.com
🔗 LinkedIn: https://www.linkedin.com/in/alvine-lumiti
🐙 GitHub: https://Mal-archLumi



# 🚀 Devkazi

**Collaborative Project Management for IT Students**

> **A mobile‑first platform empowering Kenyan IT students to build real‑world software projects in small, high‑impact teams.**

Devkazi helps students move beyond theory by practicing how real software teams work — planning, assigning roles, tracking progress, and communicating in real time.

---

## ✨ Why Devkazi?

Many students graduate without hands‑on collaboration experience. Devkazi fixes that.

* 📱 **Mobile‑first** — built for students who rely primarily on smartphones
* 🤝 **Team‑driven** — small teams that simulate real dev environments
* 🧠 **Industry‑aligned** — workflows inspired by real software teams
* 💬 **Real‑time** — instant communication, no external tools required
* 🇰🇪 **Context‑aware** — designed specifically for Kenyan universities

---

## 📖 Overview

Devkazi is a cross‑platform mobile application that provides a structured environment for IT students to:

* Form small development teams (recommended: **4 members**)
* Create and manage software projects end‑to‑end
* Break projects into phases and tasks
* Assign roles and responsibilities
* Track progress visually with timelines
* Communicate instantly via integrated team chat

The goal is simple: **make students job‑ready through collaboration, not just coursework.**

---

## 🔑 Key Features

### 🔐 Authentication

* Secure email & password registration
* JWT‑based authentication

### 👥 Team Management

* Create teams with name & description
* Invite members using unique team codes
* View members and assigned roles
* Leave or manage team membership

### 📦 Project Management

* Create projects with title, description & timeline
* Create, edit, and delete tasks
* Assign tasks to team members
* Track task status:

  * **To Do → In Progress → Completed**
* Visual progress overview & deadlines

### 💬 Real‑time Team Chat

* Dedicated chat channel per team
* Instant messaging with timestamps & sender names
* Built using **WebSockets** for smooth real‑time updates

### 🧑‍💼 Role‑based Collaboration

Common roles include:

* Frontend Developer
* Backend Developer
* UI/UX Designer
* QA / Testing
* Project Manager

### 📱 Cross‑platform Mobile Experience

* Single Flutter codebase
* Runs on **Android & iOS**

---

## 🛠 Technology Stack

| Layer                | Technology          | Purpose                      |
| -------------------- | ------------------- | ---------------------------- |
| **Frontend**         | Flutter (Dart)      | Cross‑platform mobile UI     |
| **State Management** | Provider            | Efficient app state handling |
| **HTTP Client**      | Dio                 | API requests & interceptors  |
| **Backend**          | NestJS (TypeScript) | REST API & business logic    |
| **Real‑time**        | Socket.io           | Team chat & live updates     |
| **Authentication**   | JWT                 | Secure token‑based auth      |
| **Database**         | MongoDB + Mongoose  | Flexible document storage    |
| **Hosting**          | Render              | Backend deployment           |
| **Version Control**  | Git + GitHub        | Source code management       |
| **API Testing**      | Postman             | Endpoint testing             |
| **IDE**              | VS Code             | Development environment      |

---

## 🗂 Project Structure (Simplified)

```
devkazi/
├── backend/                  # NestJS API
│   ├── src/
│   │   ├── auth/
│   │   ├── users/
│   │   ├── teams/
│   │   ├── projects/
│   │   ├── tasks/
│   │   ├── chat/
│   │   └── common/           # shared utilities & DTOs
│   └── ...
├── mobile/                   # Flutter application
│   ├── lib/
│   │   ├── core/             # constants & helpers
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
```

---

## ✅ Prerequisites

* Flutter SDK (latest stable)
* Node.js **≥ 18**
* MongoDB (local or cloud)
* Git

---

## 🚀 Getting Started

### 1️⃣ Backend Setup

```bash
# Clone repository
git clone https://github.com/yourusername/devkazi.git
cd devkazi/backend

# Install dependencies
npm install

# Environment variables
cp .env.example .env
# Add MongoDB URI & JWT secret

# Run backend
npm run start:prod
```

### 2️⃣ Mobile App Setup

```bash
cd ../mobile

# Install dependencies
flutter pub get

# Run app
flutter run
```

---

## 🤝 Contributing

Contributions are welcome and encouraged.

1. Fork the repository
2. Create a feature branch

   ```bash
   git checkout -b feature/amazing-feature
   ```
3. Commit your changes

   ```bash
   git commit -m "Add amazing feature"
   ```
4. Push to your branch

   ```bash
   git push origin feature/amazing-feature
   ```
5. Open a Pull Request

---

## 📄 License

This project is licensed under the **MIT License**.
See the `LICENSE` file for details.

---

## 👨‍💻 Author

**Makutu Alvine Lumiti**
BSc Information Technology — Mount Kenya University

* 📧 Email: [makutualvine@gmail.com](mailto:makutualvine@gmail.com)
* 🔗 LinkedIn: [https://www.linkedin.com/in/alvine-lumiti](https://www.linkedin.com/in/alvine-lumiti)
* 🐙 GitHub: [https://github.com/Mal-archLumi](https://github.com/Mal-archLumi)

---

> **Devkazi** — Build together. Learn faster. Ship smarter.

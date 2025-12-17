# README


# SkillZONE SAAS – Employee Training & Certification Management System

## Overview
SkillZONE is a SaaS application designed to help organisations manage employee training, skills development, and certification tracking. Administrators can manage employees and training programs, while employees can enrol in courses, track progress, and upload certificates upon completion.

The system follows a decoupled architecture consisting of:
- A Ruby on Rails API-only backend for business logic and data persistence
- A Flask frontend client for user interaction and view rendering

---

## Core Features CRUD 

- **Employees (Admins only)**
  - Create, update, view, and delete employee records
  - Role-based access control (Managers assigned as admins)

- **Training Courses**
  - Create, update, delete, and list training courses
  - Filter active and upcoming courses

- **Enrollments**
  - Employees enrol in courses
  - Tracks progress, grades, and completion status

- **Certificates**
  - Upload and manage proof of course completion
  - PDF files handled using Rails Active Storage

---

## Technology Stack

  - **Backend:** Ruby on Rails (API-only)
  - **Database:** PostgreSQL
  - **File Storage:** Rails Active Storage
  - **Testing:** Minitest (Rails)
  - **CI/CD:** GitHub Actions
  - **Deployment:** Render

---

## Project Setup

### Prerequisites
Ensure the following are installed:
- Ruby (version specified in `.ruby-version`)
- Rails
- PostgreSQL
- Git
- Bundler
- pip / virtualenv

---

## Render Deployed URL https://skillzone-api.onrender.com/employees
Before Initialization of the frontend enter this URL in your browser to reploy the application 
---

## Frontend Standalone repository: https://github.com/MoTECH01111/SkillZone_Frontend
 - When the API has been deployed you will see {Admin Only}
--- 
## Backend Setup Rails API

```bash
git clone https://github.com/MoTECH01111/SkillZone-Management-SaaS-Application.git
cd SkillZone-Management-SaaS-Application


Install dependencies:
bundle install
Set up the database:
rails db:create
rails db:migrate
Run the Rails API server:
rails server
API available at:
http://localhost:3000



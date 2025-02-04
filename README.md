# Ticket Support System

A ticket management system built with Flutter and Node.js that helps teams track and resolve support tickets efficiently.

## Features

### Ticket Management
- Create, view, update and delete support tickets
- Set ticket priority levels (High, Medium, Low)
- Track ticket status (Open, In Progress, Closed)
- Assign tickets to agents
- Add comments and updates to tickets
- Set due dates and estimated completion times

### Agent Management
- Create and manage support agents
- Track agent availability and workload
- Assign skills and specialties to agents
- Configure working hours and shifts

### Queue Management  
- Automatic ticket queueing system
- Smart ticket assignment based on:
  - Agent availability
  - Working hours
  - Current workload
  - Required skills
  - Ticket priority
- Real-time queue updates

### Dashboard
- Overview of ticket statistics
- Agent performance metrics
- Queue status visualization
- Priority distribution charts

## Technology Stack

- Frontend: Flutter Web
- Backend: Node.js, Express
- Database: MongoDB
- State Management: Provider
- Authentication: JWT

## Prerequisites

- Flutter SDK 3.16.0 or higher
- Node.js 18.x or higher
- MongoDB 6.0 or higher
- Git

## Local Development Setup

1. Clone the repository:
```bash
git clone https://github.com/itsivali/ticket_support_system.git
cd ticket_support_system

```markdown
# Ticket Support System

A modern, efficient ticket management solution built with Flutter Web and Node.js.

## Core Features

### Ticket Management
- CRUD operations for support tickets
- Priority levels (High/Medium/Low)
- Status tracking (Open/In Progress/Closed)
- Agent assignments
- Comment threading
- Due date management

### Agent Management
- Agent profiles and availability
- Skill tracking
- Shift scheduling
- Workload balancing

### Queue Management
- Automated ticket queueing
- Rule-based assignments
- Priority weighting
- Real-time updates

### Analytics Dashboard
- Ticket metrics
- Agent performance
- Queue analytics
- Priority distribution

## Tech Stack

- **Frontend**: Flutter Web 3.16.0+
- **Backend**: Node.js 18.x, Express
- **Database**: MongoDB 6.0


## Setup Guide

### Prerequisites

```bash
# Install Flutter
curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.16.0-stable.tar.xz
tar xf flutter_linux_3.16.0-stable.tar.xz
export PATH="$PATH:`pwd`/flutter/bin"

# Install Node.js 18.x
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install MongoDB 6.0
wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
sudo apt-get update
sudo apt-get install -y mongodb-org
```

### Local Development

1. Clone Repository
```bash
git clone https://github.com/itsivali/ticket_support_system.git
cd ticket_support_system
```

2. Frontend Setup
```bash
# Install Flutter dependencies
flutter pub get


3. Database Setup
```bash
# Start MongoDB
sudo systemctl start mongod

# Verify MongoDB status
sudo systemctl status mongod
```

4. Backend Setup
```bash
cd backend
npm install

# Create environment file
cat > .env << EOL
MONGODB_URI=mongodb://localhost:27017/ticket_support_system
PORT=3000

EOL
```

5. Seed Data
```bash
# Run all seeders
npm run seed:all
```

6. Start Services
```bash
# Terminal 1: Start backend
cd backend
npm start

# Terminal 2: Start Flutter web
cd ..
flutter run -d chrome
```

Access the app at: http://localhost:3001

## Development

### Project Structure
```
ticket_support_system/
├── lib/
│   ├── models/        # Data models
│   ├── providers/     # State management
│   ├── screens/       # UI components
│   ├── services/      # API integration
│   └── utils/         # Helpers
├── backend/
│   ├── controllers/   # API logic
│   ├── models/        # DB schemas
│   ├── routes/        # Endpoints
│   └── scripts/       # Database seeds
└── test/             # Test suites
```

### Available Scripts

```bash
# Backend
npm start          # Start server with seeding
npm run seed       # Run Node.js seeder
npm run seed:dart  # Run Dart seeder
npm run seed:all   # Run all seeders

# Frontend
flutter run -d chrome  # Development
flutter build web      # Production build
```

## Testing

```bash
# Frontend tests
flutter test

# Backend tests
cd backend && npm test
```

## Deployment

The app deploys automatically to GitHub Pages on main branch pushes.

Production URL: https://itsivali.github.io/ticket_support_system/


## License

ISC License

## Support

Create issues on GitHub repository
```

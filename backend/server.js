const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const dotenv = require('dotenv');
const ticketRoutes = require('./routes/tickets.routes');
const agentRoutes = require('./routes/agents.routes');
const shiftRoutes = require('./routes/shifts.routes');
const errorHandler = require('./middleware/errorHandler');
const seedDatabase = require('./scripts/seed');

dotenv.config();

const app = express();

const log = {
  info: (msg) => console.log(`[INFO] ${new Date().toISOString()} - ${msg}`),
  error: (msg, err) => console.error(`[ERROR] ${new Date().toISOString()} - ${msg}`, err || '')
};

// Middleware
app.use(cors());
app.use(express.json());

// Add debug logging for routes
app.use((req, res, next) => {
  log.info(`${req.method} ${req.url}`);
  next();
});

// Routes
app.use('/api/agents', agentRoutes);
app.use('/api/tickets', ticketRoutes);
app.use('/api/shifts', shiftRoutes);

// Error handling middleware
app.use(errorHandler);

async function startServer() {
  try {
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/ticket_support_system');
    log.info('Connected to MongoDB');

    // Seed the database if needed
    await seedDatabase();

    app.listen(process.env.PORT || 3000, () => {
      log.info(`Server is running on port ${process.env.PORT || 3000}`);
    });
  } catch (err) {
    log.error('Failed to connect to MongoDB', err);
    process.exit(1);
  }
}

startServer();
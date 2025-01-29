const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const dotenv = require('dotenv');
const ticketRoutes = require('./routes/tickets.routes');
const agentRoutes = require('./routes/agents');
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
app.use('/api/tickets', ticketRoutes);
app.use('/api/agents', agentRoutes);
app.use(errorHandler);

async function startServer() {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
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
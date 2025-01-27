const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const dotenv = require('dotenv');
const ticketRoutes = require('./routes/tickets');
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
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
      serverSelectionTimeoutMS: 5000,
      connectTimeoutMS: 10000,
      socketTimeoutMS: 45000
    });
    log.info('MongoDB connected successfully');

    // Seed the database
    await seedDatabase();
    log.info('Database seeded successfully');

    // Start the server
    const PORT = process.env.PORT || 3000;
    app.listen(PORT, () => {
      log.info(`Server running on port ${PORT}`);
    });

    // Handle disconnections
    mongoose.connection.on('disconnected', async () => {
      log.error('MongoDB disconnected, attempting to reconnect...');
      await connectDB();
    });

  } catch (error) {
    log.error('Server startup error:', error);
    process.exit(1);
  }
}

startServer();

module.exports = app;

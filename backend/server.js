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


app.get('/api/data', async (req, res) => {
  try {
    const tickets = await mongoose.model('Ticket').find();
    const agents = await mongoose.model('Agent').find();
    res.json({
      tickets,
      agents,
      counts: {
        tickets: tickets.length,
        agents: agents.length
      }
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

const mongooseOptions = {
  useNewUrlParser: true,
  useUnifiedTopology: true,
  serverSelectionTimeoutMS: 5000,
  connectTimeoutMS: 10000,
  socketTimeoutMS: 45000
};

async function connectDB() {
  for (let attempts = 0; attempts < 5; attempts++) {
    try {
      await mongoose.connect('mongodb://127.0.0.1:27017/ticket_system', mongooseOptions);
      log.info('MongoDB connected successfully');
      return true;
    } catch (error) {
      log.error(`MongoDB connection attempt ${attempts + 1} failed:`, error);
      if (attempts === 4) return false; // Exit after 5 attempts
      await new Promise((resolve) => setTimeout(resolve, 5000)); // Retry after 5 seconds
    }
  }
}

async function startServer() {
  try {
    const isConnected = await connectDB();
    if (!isConnected) {
      throw new Error('Failed to connect to MongoDB');
    }

    await seedDatabase();
    log.info('Database seeded successfully');

    const PORT = process.env.PORT || 3000;
    app.listen(PORT, () => {
      log.info(`Server running on port ${PORT}`);
    });

    mongoose.connection.on('disconnected', async () => {
      log.error('MongoDB disconnected, attempting to reconnect...');
      await connectDB();
    });

  } catch (error) {
    log.error('Server startup error:', error);
    setTimeout(startServer, 5000);
  }
}

startServer();

module.exports = app;

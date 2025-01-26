const mongoose = require('mongoose');
const faker = require('faker');
const Ticket = require('../models/Ticket');
const Agent = require('../models/Agent');
require('dotenv').config();

const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost/ticket_system';
const NUM_TICKETS = 20; // Number of fake tickets to generate

async function generateFakeTickets() {
  try {
    // Connect to MongoDB
    await mongoose.connect(MONGODB_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true
    });
    console.log('Connected to MongoDB');

    // Clear existing tickets
    await Ticket.deleteMany({});
    console.log('Cleared existing tickets');

    // Generate fake tickets
    const tickets = [];
    for (let i = 0; i < NUM_TICKETS; i++) {
      const dueDate = faker.date.future();
      const ticket = new Ticket({
        title: faker.hacker.phrase(),
        description: faker.lorem.paragraphs(2),
        dueDate: dueDate,
        estimatedHours: faker.datatype.number({ min: 1, max: 8 }),
        status: faker.random.arrayElement(['PENDING', 'ASSIGNED', 'IN_PROGRESS', 'COMPLETED']),
        priority: faker.random.arrayElement(['LOW', 'MEDIUM', 'HIGH']),
        createdAt: faker.date.past()
      });
      tickets.push(ticket);
    }

    // Save tickets to database
    await Ticket.insertMany(tickets);
    console.log(`Created ${NUM_TICKETS} fake tickets`);

    // Disconnect from MongoDB
    await mongoose.disconnect();
    console.log('Disconnected from MongoDB');
  } catch (error) {
    console.error('Error seeding database:', error);
    process.exit(1);
  }
}

generateFakeTickets();
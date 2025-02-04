const { faker } = require('@faker-js/faker');
const mongoose = require('mongoose');
const Ticket = require('../models/ticket.model');
const Agent = require('../models/agent.model');
require('dotenv').config();

async function seedDatabase() {
  try {
    // Clear existing data
    await mongoose.model('Ticket').deleteMany({});
    await mongoose.model('Agent').deleteMany({});

    // Create agents
    const agents = await Agent.create([
      { name: 'John Doe', email: 'john@example.com' },
      { name: 'Jane Smith', email: 'jane@example.com' },
      { name: 'Mike Wilson', email: 'mike@example.com' }
    ]);

    // Create tickets
    const tickets = await Promise.all(
      Array(20).fill().map(async () => {
        const ticket = new Ticket({
          title: faker.hacker.phrase(),
          description: faker.lorem.paragraphs(2),
          dueDate: faker.date.future(),
          estimatedHours: faker.number.int({ min: 1, max: 8 }),
          status: faker.helpers.arrayElement(['OPEN', 'IN_PROGRESS', 'CLOSED']),
          priority: faker.helpers.arrayElement(['LOW', 'MEDIUM', 'HIGH']),
          assignedTo: faker.helpers.arrayElement([...agents.map(a => a._id), null])
        });
        return ticket.save();
      })
    );

    console.log('Database seeded successfully');
    return { agents, tickets };
  } catch (error) {
    console.error('Seeding error:', error);
    throw error;
  }
}

module.exports = seedDatabase;
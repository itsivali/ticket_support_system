const { faker } = require('@faker-js/faker');
const mongoose = require('mongoose');
const Ticket = require('../models/Ticket');
const Agent = require('../models/Agent');
require('dotenv').config();

async function seedDatabase() {
  try {
    // Clear existing data
    await Promise.all([
      Ticket.deleteMany({}),
      Agent.deleteMany({})
    ]);

    // Create agents
    const agents = [
      { name: 'Agent 1' },
      { name: 'Agent 2' },
      { name: 'Agent 3' },
    ];

    await Agent.insertMany(agents);

    // Create tickets
    const tickets = await Promise.all(
      Array(20).fill().map(async () => {
        const dueDate = faker.date.future();
        const ticket = new Ticket({
          title: faker.hacker.phrase(),
          description: faker.lorem.paragraphs(2),
          dueDate,
          estimatedHours: faker.number.int({ min: 1, max: 8 }),
          status: faker.helpers.arrayElement(['PENDING', 'ASSIGNED', 'IN_PROGRESS', 'COMPLETED']),
          priority: faker.helpers.arrayElement(['LOW', 'MEDIUM', 'HIGH']),
          assignedTo: faker.helpers.arrayElement([...agents.map(a => a._id), null]),
          createdAt: faker.date.past()
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

if (require.main === module) {
  mongoose.connect(process.env.MONGODB_URI)
    .then(() => seedDatabase())
    .then(() => mongoose.disconnect())
    .catch(console.error);
}

module.exports = seedDatabase;
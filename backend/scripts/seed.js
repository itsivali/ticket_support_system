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
    const agents = await Promise.all(
      Array(5).fill().map(async () => {
        const agent = new Agent({
          name: faker.person.fullName(),
          email: faker.internet.email(),
          isOnline: faker.datatype.boolean(),
          shiftSchedule: {
            startTime: new Date().setHours(9, 0, 0, 0),
            endTime: new Date().setHours(17, 0, 0, 0),
            weekdays: [1, 2, 3, 4, 5]
          }
        });
        return agent.save();
      })
    );

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
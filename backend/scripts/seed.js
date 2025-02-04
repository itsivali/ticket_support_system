const { faker } = require('@faker-js/faker');
const mongoose = require('mongoose');
const Ticket = require('../models/ticket.model');
const Agent = require('../models/agent.model');
const Queue = require('../models/queue');

async function seedDatabase() {
  try {
    console.log('Starting database seeding...');

    // Clear existing data
    await Promise.all([
      Ticket.deleteMany({}),
      Agent.deleteMany({}),
      Queue.deleteMany({})
    ]);
    console.log('Cleared existing data');

    // Create agents with shift schedules
    const agents = await Agent.create([
      {
        name: 'John Doe',
        email: 'john@example.com',
        role: 'SUPERVISOR',
        isAvailable: true,
        isOnline: true,
        shiftSchedule: {
          startTime: new Date().setHours(9, 0, 0, 0),
          endTime: new Date().setHours(17, 0, 0, 0),
          weekdays: [1, 2, 3, 4, 5]
        }
      },
      {
        name: 'Jane Smith',
        email: 'jane@example.com',
        role: 'SUPPORT',
        isAvailable: true,
        isOnline: true,
        shiftSchedule: {
          startTime: new Date().setHours(10, 0, 0, 0),
          endTime: new Date().setHours(18, 0, 0, 0),
          weekdays: [1, 2, 3, 4, 5]
        }
      },
      {
        name: 'Mike Wilson',
        email: 'mike@example.com',
        role: 'SUPPORT',
        isAvailable: true,
        isOnline: false,
        shiftSchedule: {
          startTime: new Date().setHours(12, 0, 0, 0),
          endTime: new Date().setHours(20, 0, 0, 0),
          weekdays: [2, 3, 4, 5, 6]
        }
      }
    ]);
    console.log(`Created ${agents.length} agents`);

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
          assignedTo: faker.helpers.arrayElement([...agents.map(a => a._id), null]),
          requiredSkills: faker.helpers.arrayElements(
            ['JavaScript', 'Python', 'Java', 'React', 'Flutter', 'MongoDB', 'Node.js'],
            faker.number.int({ min: 1, max: 3 })
          )
        });
        return ticket.save();
      })
    );
    console.log(`Created ${tickets.length} tickets`);

    // Create queue with settings
    const queue = await Queue.create({
      tickets: tickets
        .filter(t => t.status === 'OPEN')
        .map(t => ({
          ticketId: t._id,
          priority: t.priority,
          addedAt: t.createdAt
        })),
      settings: {
        autoAssign: true,
        maxTicketsPerAgent: 3,
        priorityWeights: {
          HIGH: 3,
          MEDIUM: 2,
          LOW: 1
        }
      }
    });
    console.log('Created queue with settings');

    console.log('Database seeded successfully!');
    return { agents, tickets, queue };
  } catch (error) {
    console.error('Seeding error:', error);
    throw error;
  }
}

if (require.main === module) {
  mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/ticket_support_system')
    .then(() => seedDatabase())
    .then(() => mongoose.disconnect())
    .catch(err => {
      console.error('Seeding failed:', err);
      process.exit(1);
    });
} else {
  module.exports = seedDatabase;
}
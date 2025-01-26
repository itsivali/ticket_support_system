const { faker } = require('@faker-js/faker');
const Ticket = require('../models/Ticket');
const Agent = require('../models/Agent');

async function seedDatabase() {
  try {
    const count = await Ticket.countDocuments();
    if (count > 0) {
      console.log('Database already seeded');
      return;
    }

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
        const ticket = new Ticket({
          title: faker.hacker.phrase(),
          description: faker.lorem.paragraphs(2),
          dueDate: faker.date.future(),
          estimatedHours: faker.number.int({ min: 1, max: 8 }),
          status: faker.helpers.arrayElement(['PENDING', 'ASSIGNED', 'IN_PROGRESS', 'COMPLETED']),
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
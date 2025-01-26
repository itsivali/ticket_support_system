const ticketSchema = new mongoose.Schema({
    title: String,
    description: String,
    createdAt: Date,
    dueDate: Date,
    estimatedHours: Number,
    status: {
      type: String,
      enum: ['PENDING', 'ASSIGNED', 'IN_PROGRESS', 'COMPLETED']
    },
    assignedTo: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Agent'
    },
    priority: {
      type: String,
      enum: ['LOW', 'MEDIUM', 'HIGH']
    }
  });
const mongoose = require('mongoose');

const queueSchema = new mongoose.Schema({
  tickets: [{
    ticketId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Ticket'
    },
    priority: {
      type: String,
      enum: ['LOW', 'MEDIUM', 'HIGH'],
      default: 'MEDIUM'
    },
    addedAt: {
      type: Date,
      default: Date.now
    }
  }],
  settings: {
    autoAssign: {
      type: Boolean,
      default: true
    },
    maxTicketsPerAgent: {
      type: Number,
      default: 3
    },
    priorityWeights: {
      HIGH: { type: Number, default: 3 },
      MEDIUM: { type: Number, default: 2 }, 
      LOW: { type: Number, default: 1 }
    }
  }
}, { timestamps: true });

module.exports = mongoose.model('Queue', queueSchema);
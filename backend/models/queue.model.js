const mongoose = require('mongoose');

const queueSchema = new mongoose.Schema({
  tickets: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Ticket'
  }],
  autoAssignEnabled: {
    type: Boolean,
    default: true
  },
  maxTicketsPerAgent: {
    type: Number,
    default: 3
  }
}, { timestamps: true });

module.exports = mongoose.model('Queue', queueSchema);
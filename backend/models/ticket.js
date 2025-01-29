const express = require('express');
const router = express.Router();
const { Ticket, Agent } = require('../models');
const mongoose = require('mongoose');

const ticketSchema = new mongoose.Schema({
  title: {
    type: String,
    required: [true, 'Title is required'],
    minlength: [3, 'Title must be at least 3 characters']
  },
  description: {
    type: String,
    required: [true, 'Description is required'],
    minlength: [10, 'Description must be at least 10 characters']
  },
  dueDate: {
    type: Date,
    required: true
  },
  estimatedHours: {
    type: Number,
    required: true,
    min: 0.5
  },
  status: {
    type: String,
    enum: ['OPEN', 'IN_PROGRESS', 'CLOSED'],
    default: 'OPEN'
  },
  priority: {
    type: String,
    enum: ['LOW', 'MEDIUM', 'HIGH'],
    default: 'MEDIUM'
  },
  assignedTo: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Agent',
    default: null
  }
}, {
  timestamps: true
});

// Create indexes
ticketSchema.index({ status: 1, priority: 1 });
ticketSchema.index({ assignedTo: 1 });
ticketSchema.index({ createdAt: -1 });

// Only create the model if it hasn't been created already
const Ticket = mongoose.models.Ticket || mongoose.model('Ticket', ticketSchema);

module.exports = Ticket;

// Get all tickets
router.get('/', async (req, res) => {
  try {
    const tickets = await Ticket.find().populate('assignedTo');
    res.json(tickets);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Get a single ticket by ID
router.get('/:id', getTicket, (req, res) => {
  res.json(res.ticket);
});

// Create a new ticket
router.post('/', async (req, res) => {
  const ticket = new Ticket({
    title: req.body.title,
    description: req.body.description,
    dueDate: req.body.dueDate,
    estimatedHours: req.body.estimatedHours,
    status: req.body.status,
    priority: req.body.priority,
    assignedTo: req.body.assignedTo || null,
  });

  try {
    const newTicket = await ticket.save();
    res.status(201).json(newTicket);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

// Update a ticket
router.put('/:id', getTicket, async (req, res) => {
  if (req.body.title != null) {
    res.ticket.title = req.body.title;
  }
  if (req.body.description != null) {
    res.ticket.description = req.body.description;
  }
  if (req.body.dueDate != null) {
    res.ticket.dueDate = req.body.dueDate;
  }
  if (req.body.estimatedHours != null) {
    res.ticket.estimatedHours = req.body.estimatedHours;
  }
  if (req.body.status != null) {
    res.ticket.status = req.body.status;
  }
  if (req.body.priority != null) {
    res.ticket.priority = req.body.priority;
  }
  if (req.body.assignedTo !== undefined) {
    res.ticket.assignedTo = req.body.assignedTo;
  }

  try {
    const updatedTicket = await res.ticket.save();
    res.json(updatedTicket);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

// Delete a ticket
router.delete('/:id', async (req, res) => {
  try {
    const ticket = await Ticket.findByIdAndDelete(req.params.id);
    if (!ticket) {
      return res.status(404).json({ message: 'Cannot find ticket' });
    }
    res.json({ message: 'Deleted Ticket' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Middleware to get ticket by ID
async function getTicket(req, res, next) {
  let ticket;
  try {
    ticket = await Ticket.findById(req.params.id).populate('assignedTo');
    if (ticket == null) {
      return res.status(404).json({ message: 'Cannot find ticket' });
    }
  } catch (err) {
    return res.status(500).json({ message: err.message });
  }

  res.ticket = ticket;
  next();
}

module.exports = router;
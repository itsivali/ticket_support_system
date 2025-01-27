const express = require('express');
const router = express.Router();
const { Ticket } = require('../models');

// Get all tickets
router.get('/', async (req, res) => {
  try {
    const tickets = await Ticket.find();
    res.json(tickets);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
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
    assignedTo: req.body.assignedTo,
  });

  try {
    const newTicket = await ticket.save();
    res.status(201).json(newTicket);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

// Assign a ticket to an agent
router.patch('/:id/assign', async (req, res) => {
  try {
    const ticket = await Ticket.findById(req.params.id);
    if (!ticket) {
      return res.status(404).json({ message: 'Ticket not found' });
    }

    ticket.assignedTo = req.body.assignedTo;
    await ticket.save();
    res.json(ticket);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

module.exports = router;
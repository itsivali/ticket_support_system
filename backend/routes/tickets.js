const express = require('express');
const router = express.Router();
const Ticket = require('../models/Ticket');
const Agent = require('../models/Agent');

// Get all tickets
router.get('/', async (req, res, next) => {
  try {
    const tickets = await Ticket.find().populate('assignedTo');
    res.json(tickets);
  } catch (err) {
    next(err);
  }
});

// Create ticket
router.post('/', async (req, res, next) => {
  try {
    const ticket = new Ticket(req.body);
    await ticket.save();
    res.status(201).json(ticket);
  } catch (err) {
    next(err);
  }
});

// Update ticket
router.put('/:id', async (req, res, next) => {
  try {
    const ticket = await Ticket.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true }
    );
    if (!ticket) return res.status(404).json({ message: 'Ticket not found' });
    res.json(ticket);
  } catch (err) {
    next(err);
  }
});

// Assign ticket
router.post('/:id/assign', async (req, res, next) => {
  try {
    const { agentId } = req.body;
    const ticket = await Ticket.findById(req.params.id);
    const agent = await Agent.findById(agentId);

    if (!ticket || !agent) {
      return res.status(404).json({ message: 'Ticket or agent not found' });
    }

    ticket.assignedTo = agentId;
    ticket.status = 'ASSIGNED';
    await ticket.save();

    agent.currentTickets.push(ticket._id);
    await agent.save();

    res.json(ticket);
  } catch (err) {
    next(err);
  }
});

module.exports = router;
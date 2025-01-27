const express = require('express');
const router = express.Router();
const Ticket = require('../models/Ticket');
const Agent = require('../models/Agent');

// Get all tickets with filters
router.get('/', async (req, res, next) => {
  try {
    const { status, priority, assignedTo } = req.query;
    const query = {};
    
    if (status) query.status = status;
    if (priority) query.priority = priority;
    if (assignedTo) query.assignedTo = assignedTo;

    const tickets = await Ticket.find(query)
      .populate('assignedTo')
      .sort('-createdAt');
    res.json(tickets);
  } catch (err) {
    next(err);
  }
});

// Get ticket by ID
router.get('/:id', async (req, res, next) => {
  try {
    const ticket = await Ticket.findById(req.params.id).populate('assignedTo');
    if (!ticket) return res.status(404).json({ message: 'Ticket not found' });
    res.json(ticket);
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
      { new: true, runValidators: true }
    ).populate('assignedTo');
    if (!ticket) return res.status(404).json({ message: 'Ticket not found' });
    res.json(ticket);
  } catch (err) {
    next(err);
  }
});

// Delete ticket
router.delete('/:id', async (req, res, next) => {
  try {
    const ticket = await Ticket.findByIdAndDelete(req.params.id);
    if (!ticket) return res.status(404).json({ message: 'Ticket not found' });
    
    if (ticket.assignedTo) {
      await Agent.findByIdAndUpdate(ticket.assignedTo, {
        $pull: { currentTickets: ticket._id }
      });
    }
    
    res.json({ message: 'Ticket deleted successfully' });
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

    // Check agent availability
    const shiftEnd = new Date(agent.shiftSchedule.endTime);
    const estimatedCompletion = new Date();
    estimatedCompletion.setHours(estimatedCompletion.getHours() + ticket.estimatedHours);

    if (estimatedCompletion > shiftEnd) {
      return res.status(400).json({ 
        message: 'Agent shift ends before estimated completion time' 
      });
    }

    ticket.assignedTo = agentId;
    ticket.status = 'ASSIGNED';
    await ticket.save();

    agent.currentTickets.push(ticket._id);
    await agent.save();

    res.json(await ticket.populate('assignedTo'));
  } catch (err) {
    next(err);
  }
});

module.exports = router;
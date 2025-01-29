const Ticket = require('../models/ticket.model');

exports.getAllTickets = async (req, res) => {
  try {
    const tickets = await Ticket.find().populate('assignedTo');
    res.json(tickets);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.getTicketById = async (req, res, next) => {
  try {
    const ticket = await Ticket.findById(req.params.id).populate('assignedTo');
    if (!ticket) {
      return res.status(404).json({ message: 'Cannot find ticket' });
    }
    res.ticket = ticket;
    next();
  } catch (err) {
    return res.status(500).json({ message: err.message });
  }
};

exports.createTicket = async (req, res) => {
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
};

exports.updateTicket = async (req, res) => {
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
};

exports.deleteTicket = async (req, res) => {
  try {
    const ticket = await Ticket.findByIdAndDelete(req.params.id);
    if (!ticket) {
      return res.status(404).json({ message: 'Cannot find ticket' });
    }
    res.json({ message: 'Deleted Ticket' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
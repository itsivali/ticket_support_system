const Ticket = require('../models/ticket.model');
const Agent = require('../models/agent');

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

exports.assignTicket = async (req, res) => {
  try {
    const ticket = await Ticket.findById(req.params.id);
    if (!ticket) {
      return res.status(404).json({ message: 'Ticket not found' });
    }

    const agentId = req.body.assignedTo;
    if (agentId) {
      const agent = await Agent.findById(agentId);
      if (!agent) {
        return res.status(404).json({ message: 'Agent not found' });
      }

      // Check agent availability and shift
      if (!agent.isAvailable || !agent.isOnline) {
        return res.status(400).json({ message: 'Agent is not available' });
      }

      // Check if agent's shift ends before ticket due date
      if (agent.shiftSchedule && ticket.dueDate > agent.shiftSchedule.endTime) {
        return res.status(400).json({ 
          message: 'Agent shift ends before ticket due date' 
        });
      }

      ticket.assignedTo = agentId;
      ticket.status = 'IN_PROGRESS';
      agent.currentTickets.push(ticket._id);
      
      await Promise.all([ticket.save(), agent.save()]);
    } else {
      // Queue the ticket
      ticket.assignedTo = null;
      ticket.status = 'OPEN';
      await ticket.save();
      
      // Try auto-assignment to available agents
      await autoAssignTicket(ticket);
    }

    res.json(ticket);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.claimTicket = async (req, res) => {
  try {
    const { agentId } = req.body;
    const ticket = await Ticket.findById(req.params.id);
    
    if (!ticket) {
      return res.status(404).json({ message: 'Ticket not found' });
    }

    if (ticket.assignedTo) {
      return res.status(400).json({ message: 'Ticket is already assigned' });
    }

    const agent = await Agent.findById(agentId);
    if (!agent) {
      return res.status(404).json({ message: 'Agent not found' });
    }

    // Validate agent can claim ticket
    if (!agent.isAvailable || !agent.isOnline) {
      return res.status(400).json({ message: 'Agent is not available' });
    }

    if (agent.currentTickets.length >= 3) {
      return res.status(400).json({ message: 'Agent has maximum tickets' });
    }

    ticket.assignedTo = agentId;
    ticket.status = 'IN_PROGRESS';
    agent.currentTickets.push(ticket._id);

    await Promise.all([ticket.save(), agent.save()]);
    res.json(ticket);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

async function autoAssignTicket(ticket) {
  const availableAgents = await Agent.find({
    isAvailable: true,
    isOnline: true,
    'currentTickets.length': { $lt: 3 }
  });

  for (const agent of availableAgents) {
    if (canAssignTicketToAgent(ticket, agent)) {
      ticket.assignedTo = agent._id;
      ticket.status = 'IN_PROGRESS';
      agent.currentTickets.push(ticket._id);
      await Promise.all([ticket.save(), agent.save()]);
      break;
    }
  }
}

function canAssignTicketToAgent(ticket, agent) {
  if (!agent.shiftSchedule) return true;
  return ticket.dueDate <= agent.shiftSchedule.endTime;
}
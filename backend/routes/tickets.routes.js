const express = require('express');
const router = express.Router();
const ticketController = require('../controllers/ticket.controller');

router.get('/', ticketController.getAllTickets);
router.get('/:id', ticketController.getTicketById, (req, res) => {
  res.json(res.ticket);
});
router.post('/', ticketController.createTicket);
router.put('/:id', ticketController.getTicketById, ticketController.updateTicket);
router.delete('/:id', ticketController.deleteTicket);

router.patch('/:id/assign', ticketController.assignTicket);
router.post('/:id/claim', ticketController.claimTicket);

module.exports = router;



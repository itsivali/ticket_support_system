const express = require('express');
const router = express.Router();
const ticketController = require('../controllers/ticket.controller');

router.get('/', ticketController.getAllTickets);
router.post('/', ticketController.createTicket);
router.get('/queue', ticketController.getQueuedTickets);
router.post('/:id/claim', ticketController.claimTicket);
router.patch('/:id/assign', ticketController.assignTicket);
router.put('/:id', ticketController.updateTicket);
router.delete('/:id', ticketController.deleteTicket);

module.exports = router;
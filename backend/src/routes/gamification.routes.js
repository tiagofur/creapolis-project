import express from 'express';
import gamificationController from '../controllers/gamification.controller.js';
import { protect } from '../middleware/authMiddleware.js';

const router = express.Router();

router.use(protect);

router.get('/profile/:userId', gamificationController.getProfile);

export default router;
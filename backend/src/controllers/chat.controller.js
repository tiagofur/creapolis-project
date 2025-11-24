import chatService from "../services/chat.service.js";

export const createChannel = async (req, res) => {
  try {
    const channel = await chatService.createChannel({
      ...req.body,
      currentUserId: req.user.id,
    });
    res.status(201).json({ success: true, data: channel });
  } catch (error) {
    res
      .status(error.statusCode || 500)
      .json({ success: false, message: error.message });
  }
};

export const getUserChannels = async (req, res) => {
  try {
    const channels = await chatService.getUserChannels(req.user.id);
    res.json({ success: true, data: channels });
  } catch (error) {
    res
      .status(error.statusCode || 500)
      .json({ success: false, message: error.message });
  }
};

export const getChannel = async (req, res) => {
  try {
    const { channelId } = req.params;
    const { limit, before } = req.query;
    const data = await chatService.getChannel(channelId, req.user.id, {
      limit: parseInt(limit),
      before,
    });
    res.json({ success: true, data });
  } catch (error) {
    res
      .status(error.statusCode || 500)
      .json({ success: false, message: error.message });
  }
};

export const sendMessage = async (req, res) => {
  try {
    const { channelId } = req.params;
    const message = await chatService.sendMessage({
      channelId,
      senderId: req.user.id,
      ...req.body,
    });
    res.status(201).json({ success: true, data: message });
  } catch (error) {
    res
      .status(error.statusCode || 500)
      .json({ success: false, message: error.message });
  }
};

export const markAsRead = async (req, res) => {
  try {
    const { channelId } = req.params;
    await chatService.markAsRead(channelId, req.user.id);
    res.json({ success: true });
  } catch (error) {
    res
      .status(error.statusCode || 500)
      .json({ success: false, message: error.message });
  }
};

import mediaService from "../services/media.service.js";

class MediaController {
  async presign(req, res, next) {
    try {
      const userId = req.user.id;
      const { folder, filename, contentType } = req.body;
      const allowed = ["image/png", "image/jpeg", "image/webp"];
      if (!filename || !contentType || !allowed.includes(contentType)) {
        return res.status(400).json({ success: false, message: "filename and contentType are required" });
      }
      const key = mediaService.buildKey({ userId, folder: folder || "uploads", filename });
      const signed = await mediaService.presignPutUrl({ key, contentType });
      if (!signed) {
        return res.status(503).json({ success: false, message: "AWS S3 not configured" });
      }
      return res.json({ success: true, data: signed });
    } catch (e) {
      next(e);
    }
  }
}

const mediaController = new MediaController();
export default mediaController;
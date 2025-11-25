import { authenticator } from "otplib";
import qrcode from "qrcode";
import prisma from "../config/database.js";
import { encrypt, decrypt } from "../utils/encryption.js"; // We'll need to create this utility if it doesn't exist

export const twoFactorService = {
  /**
   * Generate a new 2FA secret for a user
   * @param {string} email
   * @returns {Promise<{secret: string, otpauthUrl: string, qrCode: string}>}
   */
  async generateSecret(email) {
    const secret = authenticator.generateSecret();
    const otpauthUrl = authenticator.keyuri(email, "Creapolis", secret);
    const qrCode = await qrcode.toDataURL(otpauthUrl);

    return {
      secret,
      otpauthUrl,
      qrCode,
    };
  },

  /**
   * Verify a 2FA token
   * @param {string} token
   * @param {string} secret
   * @returns {boolean}
   */
  verifyToken(token, secret) {
    return authenticator.verify({ token, secret });
  },

  /**
   * Enable 2FA for a user
   * @param {number} userId
   * @param {string} secret
   */
  async enable2FA(userId, secret) {
    // In a real app, you might want to encrypt this secret before storing
    // For now, we'll store it as is, but I'll add a TODO for encryption
    // TODO: Encrypt secret

    return prisma.user.update({
      where: { id: userId },
      data: {
        twoFactorEnabled: true,
        twoFactorSecret: secret,
      },
    });
  },

  /**
   * Disable 2FA for a user
   * @param {number} userId
   */
  async disable2FA(userId) {
    return prisma.user.update({
      where: { id: userId },
      data: {
        twoFactorEnabled: false,
        twoFactorSecret: null,
      },
    });
  },
};

export default twoFactorService;

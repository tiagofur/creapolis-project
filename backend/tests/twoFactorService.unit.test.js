import { jest } from "@jest/globals";
import twoFactorService from "../src/services/two-factor.service.js";

// Mock dependencies
jest.mock("../src/config/database.js", () => ({
  __esModule: true,
  default: {
    user: {
      update: jest.fn(),
    },
  },
}));

jest.mock("otplib", () => ({
  authenticator: {
    generateSecret: jest.fn(() => "MOCK_SECRET"),
    keyuri: jest.fn(
      () =>
        "otpauth://totp/Creapolis:test@example.com?secret=MOCK_SECRET&issuer=Creapolis"
    ),
    verify: jest.fn(),
  },
}));

jest.mock("qrcode", () => ({
  toDataURL: jest.fn(() => Promise.resolve("data:image/png;base64,mockqrcode")),
}));

// Import mocked modules to assert on them
import prisma from "../src/config/database.js";
import { authenticator } from "otplib";
import qrcode from "qrcode";

describe("TwoFactorService Unit Tests", () => {
  afterEach(() => {
    jest.clearAllMocks();
  });

  describe("generateSecret", () => {
    it("should generate a secret, otpauthUrl, and qrCode", async () => {
      const email = "test@example.com";
      const result = await twoFactorService.generateSecret(email);

      expect(authenticator.generateSecret).toHaveBeenCalled();
      expect(authenticator.keyuri).toHaveBeenCalledWith(
        email,
        "Creapolis",
        "MOCK_SECRET"
      );
      expect(qrcode.toDataURL).toHaveBeenCalledWith(
        "otpauth://totp/Creapolis:test@example.com?secret=MOCK_SECRET&issuer=Creapolis"
      );

      expect(result).toEqual({
        secret: "MOCK_SECRET",
        otpauthUrl:
          "otpauth://totp/Creapolis:test@example.com?secret=MOCK_SECRET&issuer=Creapolis",
        qrCode: "data:image/png;base64,mockqrcode",
      });
    });
  });

  describe("verifyToken", () => {
    it("should return true for valid token", () => {
      authenticator.verify.mockReturnValue(true);
      const result = twoFactorService.verifyToken("123456", "SECRET");
      expect(authenticator.verify).toHaveBeenCalledWith({
        token: "123456",
        secret: "SECRET",
      });
      expect(result).toBe(true);
    });

    it("should return false for invalid token", () => {
      authenticator.verify.mockReturnValue(false);
      const result = twoFactorService.verifyToken("wrong", "SECRET");
      expect(result).toBe(false);
    });
  });

  describe("enable2FA", () => {
    it("should update user with 2FA enabled and secret", async () => {
      const userId = 1;
      const secret = "SECRET";
      prisma.user.update.mockResolvedValue({ id: 1, twoFactorEnabled: true });

      await twoFactorService.enable2FA(userId, secret);

      expect(prisma.user.update).toHaveBeenCalledWith({
        where: { id: userId },
        data: {
          twoFactorEnabled: true,
          twoFactorSecret: secret,
        },
      });
    });
  });

  describe("disable2FA", () => {
    it("should update user with 2FA disabled and null secret", async () => {
      const userId = 1;
      prisma.user.update.mockResolvedValue({ id: 1, twoFactorEnabled: false });

      await twoFactorService.disable2FA(userId);

      expect(prisma.user.update).toHaveBeenCalledWith({
        where: { id: userId },
        data: {
          twoFactorEnabled: false,
          twoFactorSecret: null,
        },
      });
    });
  });
});

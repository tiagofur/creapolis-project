import { validationResult } from "express-validator";
import { ErrorResponses } from "../utils/errors.js";

/**
 * Middleware to validate request using express-validator
 */
export const validate = (req, res, next) => {
  const errors = validationResult(req);

  if (!errors.isEmpty()) {
    const errorMessages = errors.array().map((error) => ({
      field: error.path,
      message: error.msg,
    }));

    throw ErrorResponses.badRequest("Validation failed", errorMessages);
  }

  next();
};

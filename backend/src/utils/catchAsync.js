// Factory function to catch async errors and pass them to the global error handler
export const catchAsync = (fn) => (req, res, next) => {
  Promise.resolve(fn(req, res, next)).catch(next);
};

import searchService from "../services/search.service.js";
import { ErrorResponses } from "../utils/errors.js";

/**
 * Search Controller
 * Handles HTTP requests for search functionality
 */
class SearchController {
  /**
   * Global search endpoint
   * @route GET /api/search
   */
  async globalSearch(req, res, next) {
    try {
      const userId = req.user.id;
      const { q, query } = req.query;
      const searchQuery = q || query;

      if (!searchQuery || searchQuery.trim().length < 2) {
        return res.status(400).json({
          success: false,
          message: "Search query must be at least 2 characters",
        });
      }

      // Parse filters from query params
      const filters = {
        entityTypes: req.query.types
          ? req.query.types.split(",")
          : ["task", "project", "user"],
        status: req.query.status,
        priority: req.query.priority,
        assigneeId: req.query.assigneeId,
        projectId: req.query.projectId,
        startDate: req.query.startDate,
        endDate: req.query.endDate,
      };

      const page = parseInt(req.query.page) || 1;
      const limit = parseInt(req.query.limit) || 20;

      const results = await searchService.globalSearch(userId, {
        query: searchQuery.trim(),
        filters,
        page,
        limit,
      });

      res.status(200).json({
        success: true,
        data: results,
      });
    } catch (error) {
      console.error("Global search error:", error);
      next(error);
    }
  }

  /**
   * Quick search for autocomplete
   * @route GET /api/search/quick
   */
  async quickSearch(req, res, next) {
    try {
      const userId = req.user.id;
      const { q, query } = req.query;
      const searchQuery = q || query;

      if (!searchQuery || searchQuery.trim().length < 2) {
        return res.status(200).json({
          success: true,
          data: { suggestions: [] },
        });
      }

      const limit = parseInt(req.query.limit) || 5;

      const results = await searchService.quickSearch(
        userId,
        searchQuery.trim(),
        limit
      );

      res.status(200).json({
        success: true,
        data: results,
      });
    } catch (error) {
      console.error("Quick search error:", error);
      next(error);
    }
  }

  /**
   * Search tasks only
   * @route GET /api/search/tasks
   */
  async searchTasks(req, res, next) {
    try {
      const userId = req.user.id;
      const { q, query } = req.query;
      const searchQuery = q || query;

      if (!searchQuery || searchQuery.trim().length < 2) {
        return res.status(400).json({
          success: false,
          message: "Search query must be at least 2 characters",
        });
      }

      const filters = {
        entityTypes: ["task"],
        status: req.query.status,
        priority: req.query.priority,
        assigneeId: req.query.assigneeId,
        projectId: req.query.projectId,
        startDate: req.query.startDate,
        endDate: req.query.endDate,
      };

      const page = parseInt(req.query.page) || 1;
      const limit = parseInt(req.query.limit) || 20;

      const results = await searchService.globalSearch(userId, {
        query: searchQuery.trim(),
        filters,
        page,
        limit,
      });

      res.status(200).json({
        success: true,
        data: {
          tasks: results.results.tasks,
          totalResults: results.results.tasks.length,
          query: searchQuery,
          page,
          limit,
        },
      });
    } catch (error) {
      console.error("Task search error:", error);
      next(error);
    }
  }

  /**
   * Search projects only
   * @route GET /api/search/projects
   */
  async searchProjects(req, res, next) {
    try {
      const userId = req.user.id;
      const { q, query } = req.query;
      const searchQuery = q || query;

      if (!searchQuery || searchQuery.trim().length < 2) {
        return res.status(400).json({
          success: false,
          message: "Search query must be at least 2 characters",
        });
      }

      const filters = {
        entityTypes: ["project"],
      };

      const page = parseInt(req.query.page) || 1;
      const limit = parseInt(req.query.limit) || 20;

      const results = await searchService.globalSearch(userId, {
        query: searchQuery.trim(),
        filters,
        page,
        limit,
      });

      res.status(200).json({
        success: true,
        data: {
          projects: results.results.projects,
          totalResults: results.results.projects.length,
          query: searchQuery,
          page,
          limit,
        },
      });
    } catch (error) {
      console.error("Project search error:", error);
      next(error);
    }
  }

  /**
   * Search users only
   * @route GET /api/search/users
   */
  async searchUsers(req, res, next) {
    try {
      const userId = req.user.id;
      const { q, query } = req.query;
      const searchQuery = q || query;

      if (!searchQuery || searchQuery.trim().length < 2) {
        return res.status(400).json({
          success: false,
          message: "Search query must be at least 2 characters",
        });
      }

      const filters = {
        entityTypes: ["user"],
      };

      const page = parseInt(req.query.page) || 1;
      const limit = parseInt(req.query.limit) || 20;

      const results = await searchService.globalSearch(userId, {
        query: searchQuery.trim(),
        filters,
        page,
        limit,
      });

      res.status(200).json({
        success: true,
        data: {
          users: results.results.users,
          totalResults: results.results.users.length,
          query: searchQuery,
          page,
          limit,
        },
      });
    } catch (error) {
      console.error("User search error:", error);
      next(error);
    }
  }
}

export default new SearchController();

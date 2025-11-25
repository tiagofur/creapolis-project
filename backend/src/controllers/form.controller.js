const formService = require("../services/form.service");

class FormController {
  async createForm(req, res) {
    try {
      const { projectId } = req.params;
      const form = await formService.createForm(
        projectId,
        req.user.id,
        req.body
      );
      res.status(201).json(form);
    } catch (error) {
      res.status(500).json({ message: error.message });
    }
  }

  async getFormsByProject(req, res) {
    try {
      const { projectId } = req.params;
      const forms = await formService.getFormsByProject(projectId);
      res.json(forms);
    } catch (error) {
      res.status(500).json({ message: error.message });
    }
  }

  async getFormById(req, res) {
    try {
      const { formId } = req.params;
      const form = await formService.getFormById(formId);
      if (!form) return res.status(404).json({ message: "Form not found" });
      res.json(form);
    } catch (error) {
      res.status(500).json({ message: error.message });
    }
  }

  async updateForm(req, res) {
    try {
      const { formId } = req.params;
      const form = await formService.updateForm(formId, req.body);
      res.json(form);
    } catch (error) {
      res.status(500).json({ message: error.message });
    }
  }

  async deleteForm(req, res) {
    try {
      const { formId } = req.params;
      await formService.deleteForm(formId);
      res.json({ message: "Form deleted successfully" });
    } catch (error) {
      res.status(500).json({ message: error.message });
    }
  }

  // Public endpoints
  async getPublicForm(req, res) {
    try {
      const { publicLink } = req.params;
      const form = await formService.getFormByPublicLink(publicLink);
      res.json(form);
    } catch (error) {
      res.status(404).json({ message: error.message });
    }
  }

  async submitPublicForm(req, res) {
    try {
      const { publicLink } = req.params;
      const ipAddress = req.ip || req.connection.remoteAddress;
      const userAgent = req.get("User-Agent");

      const result = await formService.submitForm(
        publicLink,
        req.body,
        ipAddress,
        userAgent
      );
      res.status(201).json(result);
    } catch (error) {
      res.status(400).json({ message: error.message });
    }
  }
}

module.exports = new FormController();

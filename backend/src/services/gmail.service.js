import { google } from 'googleapis';
import prisma from '../prisma/client.js';
import emailToTaskService from './emailToTask.service.js';

class GmailService {
  constructor() {
    this.oauth2Client = new google.auth.OAuth2(
      process.env.GOOGLE_CLIENT_ID,
      process.env.GOOGLE_CLIENT_SECRET,
      process.env.GOOGLE_REDIRECT_URI
    );
  }

  async setCredentials(userId) {
    const user = await prisma.user.findUnique({ where: { id: userId } });
    if (!user || !user.googleAccessToken || !user.googleRefreshToken) {
      throw new Error('User not authenticated with Google');
    }
    this.oauth2Client.setCredentials({
      access_token: user.googleAccessToken,
      refresh_token: user.googleRefreshToken,
    });
  }

  async watchInbox(userId) {
    await this.setCredentials(userId);
    const gmail = google.gmail({ version: 'v1', auth: this.oauth2Client });
    await gmail.users.watch({
      userId: 'me',
      requestBody: {
        labelIds: ['INBOX'],
        topicName: process.env.GOOGLE_PUB_SUB_TOPIC,
      },
    });
  }

  async processNewEmails(userId) {
    await this.setCredentials(userId);
    const gmail = google.gmail({ version: 'v1', auth: this.oauth2Client });

    const response = await gmail.users.messages.list({
      userId: 'me',
      q: 'is:unread label:inbox',
    });

    const messages = response.data.messages || [];

    for (const message of messages) {
      const emailResponse = await gmail.users.messages.get({
        userId: 'me',
        id: message.id,
        format: 'raw',
      });
      const rawEmail = Buffer.from(emailResponse.data.raw, 'base64').toString('utf-8');
      
      // TODO: Get workspaceId and projectId from somewhere
      const workspaceId = 1; 
      const projectId = 1;

      await emailToTaskService.createTaskFromEmail(rawEmail, workspaceId, projectId);

      await gmail.users.messages.modify({
        userId: 'me',
        id: message.id,
        requestBody: {
          removeLabelIds: ['UNREAD'],
        },
      });
    }
  }
}

export default new GmailService();

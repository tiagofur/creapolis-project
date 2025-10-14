import websocketService from "../services/websocket.service.js";

/**
 * Get active users in a collaboration room
 */
export const getActiveUsers = async (req, res) => {
  try {
    const { roomId } = req.params;

    const activeUsers = websocketService.getActiveUsers(roomId);

    res.json({
      success: true,
      data: {
        roomId,
        activeUsers,
        count: activeUsers.length,
      },
    });
  } catch (error) {
    console.error("Error getting active users:", error);
    res.status(500).json({
      success: false,
      error: "Failed to get active users",
    });
  }
};

/**
 * Broadcast a message to a collaboration room
 */
export const broadcastToRoom = async (req, res) => {
  try {
    const { roomId } = req.params;
    const { event, data } = req.body;

    if (!event) {
      return res.status(400).json({
        success: false,
        error: "Event name is required",
      });
    }

    websocketService.broadcastToRoom(roomId, event, data);

    res.json({
      success: true,
      message: "Message broadcasted successfully",
    });
  } catch (error) {
    console.error("Error broadcasting to room:", error);
    res.status(500).json({
      success: false,
      error: "Failed to broadcast message",
    });
  }
};

/**
 * Resolve content conflict (last-write-wins strategy)
 */
export const resolveConflict = async (req, res) => {
  try {
    const { localVersion, remoteVersion, strategy = "last-write-wins" } = req.body;

    if (!localVersion || !remoteVersion) {
      return res.status(400).json({
        success: false,
        error: "Both local and remote versions are required",
      });
    }

    let resolvedVersion;

    switch (strategy) {
      case "last-write-wins":
        // Compare timestamps and choose the latest
        const localTime = new Date(localVersion.updatedAt || localVersion.timestamp);
        const remoteTime = new Date(remoteVersion.updatedAt || remoteVersion.timestamp);
        resolvedVersion = remoteTime > localTime ? remoteVersion : localVersion;
        break;

      case "remote-wins":
        resolvedVersion = remoteVersion;
        break;

      case "local-wins":
        resolvedVersion = localVersion;
        break;

      default:
        return res.status(400).json({
          success: false,
          error: "Invalid conflict resolution strategy",
        });
    }

    res.json({
      success: true,
      data: {
        resolvedVersion,
        strategy,
      },
    });
  } catch (error) {
    console.error("Error resolving conflict:", error);
    res.status(500).json({
      success: false,
      error: "Failed to resolve conflict",
    });
  }
};

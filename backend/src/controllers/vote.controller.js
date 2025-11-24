import prisma from "../config/database.js";
import gamificationService from "../services/gamification.service.js";
import { AppError } from "../utils/errors.js";

export const voteOnPost = async (req, res, next) => {
  try {
    const { postId } = req.params;
    const { voteType } = req.body;
    const userId = req.user.id;

    if (!["UPVOTE", "DOWNVOTE"].includes(voteType)) {
      return next(new AppError("Tipo de voto inválido", 400));
    }

    // Verificar si el post existe
    const post = await prisma.forumPost.findUnique({
      where: { id: parseInt(postId) },
      include: {
        author: true,
        thread: true,
      },
    });

    if (!post) {
      return next(new AppError("Mensaje no encontrado", 404));
    }

    // Verificar si el usuario ya votó
    const existingVote = await prisma.forumPostVote.findUnique({
      where: {
        postId_userId: {
          postId: parseInt(postId),
          userId: userId,
        },
      },
    });

    let result;
    let reputationChange = 0;

    if (existingVote) {
      if (existingVote.voteType === voteType) {
        // Eliminar voto (toggle off)
        await prisma.forumPostVote.delete({
          where: { id: existingVote.id },
        });

        // Actualizar contadores
        if (voteType === "UPVOTE") {
          await prisma.forumPost.update({
            where: { id: parseInt(postId) },
            data: { upvotes: { decrement: 1 } },
          });
          reputationChange =
            -gamificationService.reputationRules.UPVOTE_RECEIVED;
        } else {
          await prisma.forumPost.update({
            where: { id: parseInt(postId) },
            data: { downvotes: { decrement: 1 } },
          });
          reputationChange =
            -gamificationService.reputationRules.DOWNVOTE_RECEIVED;
        }

        result = { action: "removed", voteType };
      } else {
        // Cambiar tipo de voto
        await prisma.forumPostVote.update({
          where: { id: existingVote.id },
          data: { voteType },
        });

        // Actualizar contadores
        if (voteType === "UPVOTE") {
          await prisma.forumPost.update({
            where: { id: parseInt(postId) },
            data: {
              upvotes: { increment: 1 },
              downvotes: { decrement: 1 },
            },
          });
          reputationChange =
            gamificationService.reputationRules.UPVOTE_RECEIVED -
            gamificationService.reputationRules.DOWNVOTE_RECEIVED;
        } else {
          await prisma.forumPost.update({
            where: { id: parseInt(postId) },
            data: {
              upvotes: { decrement: 1 },
              downvotes: { increment: 1 },
            },
          });
          reputationChange =
            gamificationService.reputationRules.DOWNVOTE_RECEIVED -
            gamificationService.reputationRules.UPVOTE_RECEIVED;
        }

        result = { action: "changed", voteType };
      }
    } else {
      // Crear nuevo voto
      await prisma.forumPostVote.create({
        data: {
          postId: parseInt(postId),
          userId: userId,
          voteType,
        },
      });

      // Actualizar contadores
      if (voteType === "UPVOTE") {
        await prisma.forumPost.update({
          where: { id: parseInt(postId) },
          data: { upvotes: { increment: 1 } },
        });
        reputationChange = gamificationService.reputationRules.UPVOTE_RECEIVED;
      } else {
        await prisma.forumPost.update({
          where: { id: parseInt(postId) },
          data: { downvotes: { increment: 1 } },
        });
        reputationChange =
          gamificationService.reputationRules.DOWNVOTE_RECEIVED;
      }

      result = { action: "added", voteType };
    }

    // Actualizar score del post
    const updatedPost = await prisma.forumPost.update({
      where: { id: parseInt(postId) },
      data: {
        score: {
          increment: reputationChange,
        },
      },
    });

    // Actualizar reputación del autor del post (si no es el mismo usuario)
    if (post.authorId !== userId && reputationChange !== 0) {
      await gamificationService.awardPoints(
        post.authorId,
        reputationChange,
        `${voteType}_RECEIVED`,
        "ForumPost",
        postId
      );
    }

    // Actualizar reputación del usuario que vota
    const voterReputationChange =
      voteType === "UPVOTE"
        ? gamificationService.reputationRules.UPVOTE_GIVEN
        : gamificationService.reputationRules.DOWNVOTE_GIVEN;
    await gamificationService.awardPoints(
      userId,
      voterReputationChange,
      `${voteType}_GIVEN`,
      "ForumPost",
      postId
    );

    res.status(200).json({
      success: true,
      data: {
        result,
        post: {
          id: updatedPost.id,
          upvotes: updatedPost.upvotes,
          downvotes: updatedPost.downvotes,
          score: updatedPost.score,
        },
      },
    });
  } catch (error) {
    console.error("Error al votar:", error);
    next(new AppError("Error al procesar el voto", 500));
  }
};

export const getPostVotes = async (req, res, next) => {
  try {
    const { postId } = req.params;
    const userId = req.user?.id;

    const post = await prisma.forumPost.findUnique({
      where: { id: parseInt(postId) },
      select: {
        upvotes: true,
        downvotes: true,
        score: true,
      },
    });

    if (!post) {
      return next(new AppError("Mensaje no encontrado", 404));
    }

    let userVote = null;
    if (userId) {
      const vote = await prisma.forumPostVote.findUnique({
        where: {
          postId_userId: {
            postId: parseInt(postId),
            userId: userId,
          },
        },
        select: {
          voteType: true,
        },
      });
      userVote = vote?.voteType || null;
    }

    res.status(200).json({
      success: true,
      data: {
        ...post,
        userVote,
      },
    });
  } catch (error) {
    console.error("Error al obtener votos:", error);
    next(new AppError("Error al obtener votos", 500));
  }
};

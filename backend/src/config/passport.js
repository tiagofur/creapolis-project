import passport from "passport";
import { Strategy as GoogleStrategy } from "passport-google-oauth20";
import { Strategy as MicrosoftStrategy } from "passport-microsoft";
import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

passport.use(
  new GoogleStrategy(
    {
      clientID: process.env.GOOGLE_CLIENT_ID,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET,
      callbackURL:
        process.env.GOOGLE_CALLBACK_URL ||
        "http://localhost:3001/api/auth/google/callback",
    },
    async function (accessToken, refreshToken, profile, cb) {
      try {
        // Check if user exists with this googleId
        let user = await prisma.user.findUnique({
          where: { googleId: profile.id },
        });

        if (!user) {
          // Check if user exists with this email
          const email = profile.emails[0].value;
          user = await prisma.user.findUnique({
            where: { email: email },
          });

          if (user) {
            // Link account
            user = await prisma.user.update({
              where: { id: user.id },
              data: {
                googleId: profile.id,
                avatarUrl: user.avatarUrl || profile.photos[0]?.value,
              },
            });
          } else {
            // Create new user
            user = await prisma.user.create({
              data: {
                email: email,
                name: profile.displayName,
                googleId: profile.id,
                avatarUrl: profile.photos[0]?.value,
                emailVerified: true,
              },
            });
          }
        }
        return cb(null, user);
      } catch (err) {
        return cb(err);
      }
    }
  )
);

passport.use(
  new MicrosoftStrategy(
    {
      clientID: process.env.MICROSOFT_CLIENT_ID,
      clientSecret: process.env.MICROSOFT_CLIENT_SECRET,
      callbackURL:
        process.env.MICROSOFT_CALLBACK_URL ||
        "http://localhost:3001/api/auth/microsoft/callback",
      scope: ["user.read"],
    },
    async function (accessToken, refreshToken, profile, cb) {
      try {
        let user = await prisma.user.findUnique({
          where: { microsoftId: profile.id },
        });

        if (!user) {
          const email =
            profile.emails && profile.emails.length > 0
              ? profile.emails[0].value
              : null;

          if (!email) {
            return cb(new Error("No email found in Microsoft profile"));
          }

          user = await prisma.user.findUnique({
            where: { email: email },
          });

          if (user) {
            user = await prisma.user.update({
              where: { id: user.id },
              data: { microsoftId: profile.id },
            });
          } else {
            user = await prisma.user.create({
              data: {
                email: email,
                name: profile.displayName,
                microsoftId: profile.id,
                emailVerified: true,
              },
            });
          }
        }
        return cb(null, user);
      } catch (err) {
        return cb(err);
      }
    }
  )
);

export default passport;

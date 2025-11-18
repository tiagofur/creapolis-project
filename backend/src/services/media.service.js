import { S3Client, PutObjectCommand } from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";

function hasAws() {
  return (
    !!process.env.AWS_ACCESS_KEY_ID &&
    !!process.env.AWS_SECRET_ACCESS_KEY &&
    !!process.env.AWS_REGION &&
    !!process.env.AWS_S3_BUCKET
  );
}

function sanitizeSegment(s) {
  return String(s).replace(/[^a-zA-Z0-9_-]/g, "");
}

export async function presignPutUrl({ key, contentType, expiresIn = 300 }) {
  if (!hasAws()) return null;
  const client = new S3Client({ region: process.env.AWS_REGION });
  const bucket = process.env.AWS_S3_BUCKET;
  const command = new PutObjectCommand({ Bucket: bucket, Key: key, ContentType: contentType });
  const url = await getSignedUrl(client, command, { expiresIn });
  return { url, bucket, key, expiresIn };
}

export function buildKey({ userId, folder = "uploads", filename }) {
  const f = sanitizeSegment(folder);
  const name = sanitizeSegment(filename);
  return `${f}/${userId}/${name}`;
}

export default {
  presignPutUrl,
  buildKey,
  getPublicUrl(key) {
    if (process.env.AWS_S3_PUBLIC_URL) {
      return `${process.env.AWS_S3_PUBLIC_URL.replace(/\/$/, "")}/${key}`;
    }
    if (process.env.AWS_S3_BUCKET && process.env.AWS_REGION) {
      return `https://${process.env.AWS_S3_BUCKET}.s3.${process.env.AWS_REGION}.amazonaws.com/${key}`;
    }
    return null;
  },
}
# 1. Base image for the builder stage
FROM node:22-alpine AS builder

WORKDIR /app

# 2. Tell the Google Cloud SDKs where to find the credentials file.
# This variable is a standard for Google Cloud services.
ENV GOOGLE_APPLICATION_CREDENTIALS=/app/firebase-key.json

# 3. Install dependencies
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile --production=false

# 4. Copy source code AND the key file into the build context.
COPY . .
# The firebase-key.json was created by a cloudbuild.yaml step.
COPY firebase-key.json .

# 5. Build the application. The Admin SDK will now find the credentials file.
RUN yarn build

# 6. Prod image for the runner stage
FROM node:22-alpine AS runner

WORKDIR /app

# 7. Tell the Google Cloud SDKs where to find the credentials file in the final image.
ENV GOOGLE_APPLICATION_CREDENTIALS=/app/firebase-key.json

# 8. Copy only the necessary build artifacts from the builder stage
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public
# Copy the key file to the final production image.
COPY --from=builder /app/firebase-key.json .

# 9. Set production environment variables
ENV NODE_ENV=production
ENV PORT=8080
ENV HOST=0.0.0.0

# 10. Expose the port
EXPOSE 8080

# 11. Start the Next.js server
CMD ["node", "server.js"]
# 1. Base image for the builder stage
FROM node:22-alpine AS builder

WORKDIR /app

# 2. Tell the Google Cloud SDKs where to find the credentials file.
# This variable is a standard for Google Cloud services.
ENV GOOGLE_APPLICATION_CREDENTIALS=/app/firebase-key.json

# 3. Install dependencies
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile --production=false

# 4. Copy source code AND the key file into the build context.
COPY . .
# The firebase-key.json was created by a cloudbuild.yaml step.
COPY firebase-key.json .

# 5. Build the application. The Admin SDK will now find the credentials file.
RUN yarn build

# 6. Prod image for the runner stage
FROM node:22-alpine AS runner

WORKDIR /app

# 7. Tell the Google Cloud SDKs where to find the credentials file in the final image.
ENV GOOGLE_APPLICATION_CREDENTIALS=/app/firebase-key.json

# 8. Copy only the necessary build artifacts from the builder stage
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public
# Copy the key file to the final production image.
COPY --from=builder /app/firebase-key.json .

# 9. Set production environment variables
ENV NODE_ENV=production
ENV PORT=8080
ENV HOST=0.0.0.0

# 10. Expose the port
EXPOSE 8080

# 11. Start the Next.js server
CMD ["node", "server.js"]

# 1. Base image for the builder stage
FROM node:22-alpine AS builder

WORKDIR /app
#test12345
# 2. Accept the Firebase config as a build argument from the 'docker build' command.
ARG FIREBASE_SERVICE_ACC_CONFIG

# 3. Set it as an environment variable ONLY for the commands in this builder stage.
# This makes the variable available to 'yarn build' but keeps it out of the final image.
ENV FIREBASE_SERVICE_ACC_CONFIG=$FIREBASE_SERVICE_ACC_CONFIG

# 4. Install dependencies
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile --production=false

# 5. Copy source code
COPY . .

# 6. Build the application. The FIREBASE_SERVICE_ACC_CONFIG variable is now available to this command.
RUN yarn build

# 7. Prod image for the runner stage
FROM node:22-alpine AS runner

WORKDIR /app

# 8. Copy only the necessary build artifacts from the builder stage
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public

# 9. Set production environment variables
ENV NODE_ENV=production
ENV PORT=8080
ENV HOST=0.0.0.0

# 10. Expose the port
EXPOSE 8080

# 11. Start the Next.js server
CMD ["node", "server.js"]

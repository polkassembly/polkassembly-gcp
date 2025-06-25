# 1. Base image
FROM node:18-alpine AS builder

WORKDIR /app

COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile --production=false

COPY . .

# 5. Uygulamayı build et
RUN yarn build

# 6. Prod image
FROM node:18-alpine AS runner

WORKDIR /app

# 7. Sadece ihtiyaç duyulan dosyalar
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public

# 8. Ortam değişkenleri
ENV NODE_ENV=production
ENV PORT=8080
ENV HOST=0.0.0.0

# 9. Port'u aç
EXPOSE 8080

# 10. Next.js'i başlat
CMD ["node", "server.js"]

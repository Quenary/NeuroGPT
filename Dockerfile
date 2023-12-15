FROM node:18-alpine AS builder
RUN apk add --no-cache libc6-compat
WORKDIR /app

COPY yarn.lock .
copy package.json .
RUN  yarn
copy . .
ENV NEXT_TELEMETRY_DISABLED 1
RUN yarn build

FROM node:18-alpine AS runner
WORKDIR /app

ENV NODE_ENV production
ENV NEXT_TELEMETRY_DISABLED 1

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

COPY --from=builder --chown=nextjs:nodejs /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/next.config.mjs .

USER nextjs

EXPOSE 3000

ENV PORT 3000

CMD ["yarn", "start"]
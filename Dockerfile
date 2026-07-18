# Stage 1: Build the application
FROM node:20-slim AS build

RUN apt-get update && apt-get install -y \
    python3 \
    build-essential \
    git \
    --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt/app
COPY package*.json ./

# Skip native compilation (better-sqlite3 only needed for local SQLite dev).
# Production uses PostgreSQL (pg) which is pure JS — no compilation needed.
RUN npm install --legacy-peer-deps --ignore-scripts

COPY . .
ENV NODE_ENV=production
RUN npm run build

# Stage 2: Lean production image
FROM node:20-slim
WORKDIR /opt/app
COPY --from=build /opt/app ./
ENV NODE_ENV=production
EXPOSE 1337
CMD ["npm", "run", "start"]


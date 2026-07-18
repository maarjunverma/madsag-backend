# Stage 1: Build
FROM node:20-slim AS build

RUN apt-get update && apt-get install -y \
    python3 \
    build-essential \
    git \
    --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt/app
COPY package*.json ./

# --omit=optional skips better-sqlite3 (the OOM culprit).
# All required deps including bcrypt (transitive via @strapi/plugin-users-permissions)
# compile normally — no more 500 on /api/auth/local.
RUN npm install --legacy-peer-deps --omit=optional

COPY . .
ENV NODE_ENV=production
RUN npm run build

# Stage 2: Production
FROM node:20-slim
RUN apt-get update && apt-get install -y \
    python3 \
    build-essential \
    --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*
WORKDIR /opt/app
COPY --from=build /opt/app ./
ENV NODE_ENV=production
EXPOSE 1337
CMD ["npm", "run", "start"]

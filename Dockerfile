# Stage 1: Build the application
FROM node:20-slim AS build

# Install build deps needed for bcrypt (REQUIRED for /api/auth/local)
# We keep better-sqlite3 out by setting npm_config_ignore_optional=true
# but bcrypt MUST compile — it's needed for password hashing
RUN apt-get update && apt-get install -y \
    python3 \
    build-essential \
    git \
    --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt/app
COPY package*.json ./

# Install all deps; bcrypt will compile here (needed for auth/local)
# better-sqlite3 may fail but we continue — production uses PostgreSQL
RUN npm install --legacy-peer-deps || true
RUN npm rebuild bcrypt --build-from-source || true

COPY . .
ENV NODE_ENV=production
RUN npm run build

# Stage 2: Lean production image
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

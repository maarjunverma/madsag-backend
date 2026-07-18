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

# Step 1: Install ALL packages without running ANY native compilation (avoids OOM from better-sqlite3)
RUN npm install --legacy-peer-deps --ignore-scripts

# Step 2: Compile ONLY bcrypt — required for /api/auth/local password hashing
# We deliberately skip better-sqlite3 since production uses PostgreSQL (DATABASE_CLIENT=postgres)
RUN npm rebuild bcrypt --build-from-source

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

# Stage 1: Build the application
FROM node:20-slim AS build

# Install system deps for native module compilation (node-gyp, sharp, better-sqlite3)
RUN apt-get update && apt-get install -y \
    build-essential \
    python3 \
    git \
    libvips-dev \
    --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt/app
COPY package*.json ./
RUN npm install --legacy-peer-deps
COPY . .
ENV NODE_ENV=production
RUN npm run build

# Stage 2: Production image
FROM node:20-slim
RUN apt-get update && apt-get install -y libvips-dev --no-install-recommends && rm -rf /var/lib/apt/lists/*
WORKDIR /opt/app
COPY --from=build /opt/app ./
ENV NODE_ENV=production
EXPOSE 1337
CMD ["npm", "run", "start"]

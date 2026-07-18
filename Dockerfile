# Stage 1: Build the application
FROM node:20-alpine AS build
RUN apk update && apk add --no-cache build-base gcc autoconf automake zlib-dev libpng-dev vips-dev git python3
WORKDIR /opt/app
COPY package*.json ./
RUN npm install --legacy-peer-deps
COPY . .
ENV NODE_ENV=production
RUN npm run build

# Stage 2: Production image
FROM node:20-alpine
RUN apk add --no-cache vips-dev
WORKDIR /opt/app
COPY --from=build /opt/app ./
ENV NODE_ENV=production
EXPOSE 1337
CMD ["npm", "run", "start"]

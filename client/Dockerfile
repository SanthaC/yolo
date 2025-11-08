# Use an official Node runtime as a parent image
FROM node:18-slim AS build

# Set the working directory in the container
WORKDIR /usr/src/app

# Copy the package.json and package-lock.json files to the container
COPY package*.json ./

# Install application dependencies
RUN npm install

# Copy the rest of the application code to the container
COPY . .

# CRITICAL FIX: Set NODE_OPTIONS to use the legacy OpenSSL provider
# This resolves the 'digital envelope routines::unsupported' error for Node 17+ builds.
RUN NODE_OPTIONS=--openssl-legacy-provider npm run build


#--Stge 2: Serving Phase---
FROM node:18-slim

#Install the 'serve' utility globally, as this is typically used in client kubernetes deployments
RUN npm install -g serve
WORKDIR /app

COPY --from=build /usr/src/app /app

# Expose the port the app runs on
EXPOSE 3000

# Command to run the production build
# We tell 'serve' to run the content of the 'build' folder on port 3000
CMD [ "serve", "-s", "build", "-l", "3000" ]
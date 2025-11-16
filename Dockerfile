# Use a lightweight Node.js image
FROM node:18-alpine

# Set the working directory
WORKDIR /usr/src/app

# Copy package files first to leverage caching
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application
COPY . .

# Expose the port the app runs on
EXPOSE 3000

# Command to run the app
CMD [ "npm", "start" ]
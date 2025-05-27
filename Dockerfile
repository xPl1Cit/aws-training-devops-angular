# Use Node.js official image to build the app
FROM node:17.0.1-bullseye-slim as builder

# Set the working directory in the container
WORKDIR /app

# Install Angular CLI
RUN npm install -g @angular/cli@13

# Copy package.json and install dependencies
COPY package.json package-lock.json ./
RUN npm ci

# Copy the rest of the Angular project
COPY . .

# Build the Angular application
RUN ng build --configuration production

# Use Nginx to serve the Angular app
FROM nginx:alpine

# Copy the build files from the builder stage to the Nginx web server
COPY --from=builder /app/dist/angular /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose the port Nginx will run on
EXPOSE 80

# Default command to run Nginx
CMD ["nginx", "-g", "daemon off;"]

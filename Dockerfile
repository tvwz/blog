# Use nginx official image as the base image
FROM nginx:latest

# Remove the default nginx static assets
RUN rm -rf /usr/share/nginx/html/*

# Copy the static assets from the Jekyll _site directory
# Assume that this Dockerfile is located at the root of your project
COPY _site/ /usr/share/nginx/html/

# Expose port 80 to the outside world
EXPOSE 80

# Start nginx and keep it running in the foreground
CMD ["nginx", "-g", "daemon off;"]

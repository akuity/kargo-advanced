# Use a lightweight Nginx image
FROM nginx:1.25-alpine

# Remove default Nginx welcome page
RUN rm -rf /usr/share/nginx/html/*

# Copy the static website content
COPY index.html /usr/share/nginx/html/index.html

# Expose port 80
EXPOSE 80

# Command to run Nginx
CMD ["nginx", "-g", "daemon off;"]

# Use an official Python runtime as a parent image
FROM python:3.9-slim

# Set the working directory in the container
WORKDIR /app

# Copy the dependencies file to the working directory
COPY requirements.txt .

# Install any needed dependencies specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy the content of the local src directory to the working directory
COPY api.py .

# Specify the port number the container should expose
EXPOSE 8080

# Command to run the application using Gunicorn
# Gunicorn is a production-ready WSGI server
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "api:app"]

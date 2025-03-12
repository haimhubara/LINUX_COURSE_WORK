# Use an OpenJDK base image
FROM openjdk:17

# Set working directory inside the container
WORKDIR /app

# Copy the Java application files
COPY  Watermark.java .

# Compile the Java code
RUN javac Watermark.java

# Define the entry point for running the Java application
ENTRYPOINT ["java", "Watermark"]

#default arguments
CMD ["Haim ", "3186887777"]
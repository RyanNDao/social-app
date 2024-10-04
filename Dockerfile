# ---- Build Stage for React Frontend ----
# Use Node.js base image for building the frontend
FROM node:20.17.0 AS build-frontend
WORKDIR /app/frontend
# Copy package.json and package-lock.json (or npm-shrinkwrap.json) for npm install
COPY frontend2/package*.json ./
RUN npm install
# Copy the rest of the frontend source code
COPY frontend2/ ./
# Build the React project (production build)
RUN npm run build

# ---- Build Stage for Spring Boot Backend ----
# Use Eclipse Temurin for compiling the Java application
FROM eclipse-temurin:21-jdk AS build-backend
WORKDIR /app/backend
COPY backend/ ./
# Install dependencies without running the build
RUN ./mvnw dependency:go-offline -B
# Build the application and package it as a JAR file
RUN ./mvnw package -DskipTests

# ---- Final Stage for the compiled application ----
# Use Eclipse Temurin for running the Java application
FROM eclipse-temurin:21-jammy
WORKDIR /app
# Copy the built JAR from the build-backend stage
COPY --from=build-backend /app/backend/target/*.jar ./app.jar
# Copy the built React app from the build-frontend stage
COPY --from=build-frontend /app/frontend/dist /public
EXPOSE 8080
# Run the JAR file
CMD ["java", "-jar", "app.jar"]

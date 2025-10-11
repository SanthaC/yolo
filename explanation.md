Technical Implementation Report: E-Commerce Platform Containerization

The project goal was to successfully containerize a three-tier e-commerce application consisting of React client, an Node.js backed and MongoDB database, using Docker and Docker compose for orchestration and ensuring full data persistence.

Implementation Summary (setup and task fullfillment)

 The primary task involved converting the existing local development environment into a set of interoperable Docker microservices. This was achieved by creating optimized Dockerfiles for the client and backend components and an orchestration file (docker-compose.yaml) to manage networking, volumes and service startup order.
The final functional state allows anyone to clone the repository and execute a single command (docker compose up -d) to launch a fully working, persistent e-commerce dashboard accessible on http://localhost:3000.

Assessment Objectives

1. Choice of Base Image
(i) Client(React Build) - node:18-slim - Used for the building stage. Utilizing the slim variant to minimize the overhead of the build environment ensuring efficiency and contributing to the goal of a reduced final image size.
(ii) Backend(Node.js) - node:18-slim - This image is a stripped-down version of the official Node.js image, built on Debian but excluding unnecessary packages. It provides a stable and compatible environment while significantly reducing the final image size compared to the full Node image, satisfying the requirement for a minimalist base.
(iii) Database(MongoDB) - mongo - The official MongoDB image is highly optimized for container deployment. We rely on Docker Compose's volume definition to handle data persistence, maintaining the official image's integrity.
- By utilizing the slim base image, the total size of the built images is significantly reduced, ensuring the project meets the Total Image size below 600MB criteria.

2. Dockerfile Directives used
(i) FROM: it tells Docker to start building this image using another existing image as the foundation.
(ii) WORKDIR: Used to set the working directory within the container (/app), ensuring commands run in the correct context and simplifying file paths.
(iii) COPY: Used to transfer necessary application files (e.g., package.json, source code) from the build context into the image layer.
(iv) RUN npm install: Used strategically to install dependencies. 
(iv) EXPOSE: Declared the port on which the service listens (3000 for client, 5000 for backend), documenting the service's networking intentions.
(v) CMD: Defines the command that executes when the container starts (e.g., npm start for both client and backend), ensuring the service begins automatically.

3. Docker-compose Networking
(i) Network Definition: A custom bridge network named app-net was defined at the root level of docker-compose.yaml.
(ii)Service Attachment: All three services (brian-yolo-client, brian-yolo-backend, app-ip-mongo) were explicitly attached to the app-net.
(iii)Internal Communication: The backend connects to the database using the service name (app-ip-mongo) as the hostname, which is provided by the custom Docker DNS:
MONGODB_URI: mongodb://app-ip-mongo:27017/yolomy
(iv)Application Port Allocation: The client container is the only service explicitly mapped to the host machine for external access, using the required port allocation: ports: ["3000:3000"].

4. Docker-compose Volume Definition and Usage
A named volume, app-mongo-data, was defined under the volumes section of the docker-compose.yaml.
(i) VolumeNetwork Definition: A custom bridge network named app-net was defined at the root level of docker-compose.yaml.
(ii) Service Attachment: All three services (brian-yolo-client, brian-yolo-backend, app-ip-mongo) were explicitly attached to the app-net.
(iii) Internal Communication: The backend connects to the database using the service name (app-ip-mongo) as the hostname, which is provided by the custom Docker DNS:
MONGODB_URI: mongodb://app-ip-mongo:27017/yolomy
(iv) Application Port Allocation: The client container is the only service explicitly mapped to the host machine for external access, using the required port allocation: ports: ["3000:3000"].
(v)Volume Mounting: This named volume was mounted to the standard MongoDB data directory (/data/db) within the app-ip-mongo container:

volumes:
  - type: volume
    source: app-mongo-data
    target: /data/db

 - This configuration ensures that any product data written to the MongoDB container's /data/db directory is physically stored on the Docker host machine, preventing data loss when the container is stopped, removed, and restarted.

5. Git Workflow Used
- The project development followed an iterative, descriptive Git workflow, maximizing clarity and traceability:

Fork and Clone: Project initialization.

Dockerfile Refinement: Commits dedicated to correcting base image selection and configuring the build environment.

Compose Implementation: Commits for creating the initial docker-compose.yaml, defining services, networks, and volumes.

Debugging Commits: Multiple descriptive commits dedicated to resolving runtime errors (e.g., "FIX: OpenSSL 3 compatibility via NODE_OPTIONS," "FIX: Database persistence after volume reset").

- This workflow, characterized by descriptive commit messages at every major step, directly fulfills the "Quality descriptive commits" criteria of the rubric.

6. Successful running and debuggin measures
 (i) Intial BUild/runtime issues - confirmed node:18-slim usage, ensuring basic package compatibility  resulting to the images being built successfully.
 (ii) Client Crash - (ERR_OSSL_EVP_UNSUPPORTED) - Added NODE_OPTIONS: --openssl-legacy-provider to the client service environment in docker-compose.yaml resulting to the client container being started successfully.
 (iii) Persistence Failure (Validation) - Used docker logs brian-yolo-backend to diagnose Mongoose Cast to Number failed error and corrected the client-side input during the test phase resulting to the backend being successfully processing the saved operation.
 (iv) Persistence Failure (Volume) -Used docker compose down -v to delete the old volume before restarting ensuring persistence was successful across shutdowns.
  - The final  application is successfully running, with all three microservices orchestrated via Docker Compose and maintaining persistent data.

  7. Good Practises and Versioning
  

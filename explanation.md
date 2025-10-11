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

(iii) COPY: Used to transfer necessary application files (e.g package.json, source code) from the build context into the image layer.

(iv) RUN npm install: Used strategically to install dependencies. 

(iv) EXPOSE: Declared the port on which the service listens (3000 for client, 5000 for backend), documenting the service's networking intentions.

(v) CMD: Defines the command that executes when the container starts (e.g., npm start for both client and backend), ensuring the service begins automatically.


3. Docker-compose Networking

(i) Network Definition: A custom bridge network named app-net was defined at the root level of docker-compose.yaml.

(ii)Service Attachment: All three services (brian-yolo-client, brian-yolo-backend and app-ip-mongo) were explicitly attached to the app-net.

(iii)Internal Communication: The backend connects to the database using the service name (app-ip-mongo) as the hostname, which is provided by the custom Docker DNS:
MONGODB_URI: mongodb://app-ip-mongo:27017/yolomy

(iv)Application Port Allocation: The client container is the only service explicitly mapped to the host machine for external access, using the required port allocation: ports: ["3000:3000"].


4. Docker-compose Volume Definition and Usage

(i) Volume Definition: A named volume, app-mongo-data, was defined under the volumes section of the docker-compose.yaml.

(ii) Volume Mounting: app-mongo-data was mounted to the standard MongoDB data directory (/data/db) within the app-ip-mongo container:

 - volumes:
  - type: volume
  - source: app-mongo-data
  - target: /data/db


 - This setup guarantees that any product data saved in MongoDB’s /data/db directory is securely retained on the Docker host system, ensuring data remains intact even after container shutdowns, deletions or restarts.

5. Git Workflow Used
- The project development followed an iterative, descriptive Git workflow, maximizing clarity and traceability:

- Key stages in the process included:

(i) Initialization and Environment Setup:
The workflow began by cloning the base repository, reviewing the existing structure and configuring the local development environment to ensure compatibility with Docker and Node.js components.

(ii) Configuration and Integration:
Subsequent commits focused on verifying and refining container configurations, including adjustments to Dockerfile and docker-compose.yaml parameters to ensure seamless communication between the frontend and backend services.

(iii) Debugging and Optimization:
The most critical commits were focused on solving complex integration issues, with messages explicitly documenting the fix:
- FIX: Applied NODE_OPTIONS for OpenSSL compatibility in client container.

- FIX: Database persistence confirmed after volume cleanup ('docker-compose down -v').

- FIX: Validated numeric price input to resolve Mongoose CastError.

(iv) Finalization and Documentation:
The final commits consolidated all changes, verified container functionality and refined the project’s documentation and submission files. 

- This structured workflow maintained an organized and transparent commit record, showcasing consistent use of Git best practices while allowing straightforward tracking and assessment of the project’s progress from initialization to final deployment.

6. Successful running and debugging measures

 (i) Intial BUild/runtime issues - confirmed node:18-slim usage, ensuring basic package compatibility  resulting to the images being built successfully.

 (ii) Client Crash - (ERR_OSSL_EVP_UNSUPPORTED) - Added NODE_OPTIONS: --openssl-legacy-provider to the client service environment in docker-compose.yaml resulting to the client container being started successfully.

 (iii) Persistence Failure (Validation) - Used docker logs brian-yolo-backend to diagnose Mongoose Cast to Number failed error and corrected the client-side input during the test phase resulting to the backend being successfully processing the saved operation.

 (iv) Persistence Failure (Volume) -Used docker compose down -v to delete the old volume before restarting ensuring persistence was successful across shutdowns.

  - The final  application is successfully running, with all three microservices orchestrated via Docker Compose and maintaining persistent data.

  7. Good Practises and Versioning

(i) Versioning: Uses version: "3.8" for compatibility with modern Docker features and stable networking.

(ii) Service Separation: Frontend, backend, and database are defined as distinct services for modularity and easier management.

(iii) Clear Naming & Tagging: Uses descriptive service names and version-tagged images (e.g v1.0.0) for clarity and version control.

(iv) Custom Network: Implements a user-defined bridge network (app-net) for secure and isolated container communication.

(v)Data Persistence: Uses a named volume (app-mongo-data) to retain MongoDB data across container restarts.

(vi) Dependency Control: Applies depends_on to manage the correct startup order of services.

Restart Policy: Uses restart: always to ensure the backend restarts automatically on failure.

(vi) Environment Variables: Keeps configuration flexible and separate from code for easier management.

(vii) Documentation: Includes clear comments that explain the purpose and function of each service, improving readability and maintenance.

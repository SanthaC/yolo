# Configuration Management Independent Project (IP)

This repository contains the solution for the Configuration Management Independent Project, focusing on **Ansible** for configuration management and application deployment, with an optional but implemented **Terraform** component for infrastructure provisioning.

The project deploys a containerized e-commerce web application, leveraging a **Vagrant**-provisioned server for a local development/testing environment.

---

## 1. Project Overview

The goal of this assignment was to automate the deployment of a multi-component e-commerce application using configuration management tools. The application consists of a **Web (Frontend(Client))**, **API (Backend)** and a **Databasedb)(Mongo** component, all running as Docker containers.

The project is structured into two main stages:

### Stage 1: Ansible Instrumentation
Automates the provisioning of a Vagrant VM and the complete setup, configuration and deployment of the containerized application using only an **Ansible Playbook**.

### Stage 2: Ansible and Terraform Instrumentation
Introduces **Terraform** for infrastructure provisioning. A main Ansible playbook triggers a Terraform module to provision the Vagrant server and then continues with Ansible roles for server configuration and application deployment, offering a single command to deploy the full stack.

---
## 2. Architecture and Microservices

The application is broken down into three distinct microservices, all connected via a dedicated Docker bridge network (app-net):

(i) brain-yolo-client - React, Node.js - Frontend Dashboard - Host Port 3000

(ii) brian-yolo-backend - Node.js - REST API Server - Internal Port 5000

(iii) app-ip-mongo - MongoDB - Data Storage - Internal Port 27017

## 3. Repository Structure

The repository is organized to clearly delineate the two stages of the project and adhere to Ansible and Terraform best practices, including the use of roles, variables, and proper file separation.


```
YOLO/
├── .vscode/
│   └── settings.json
├── backend/               #Backend(Node.js)
│   ├── models/
│   │   └── Products.js
│   ├── node_modules/
│   ├── routes/api/        # Defines API endpoints
│   │   └── productRoute.js
│   ├── .gitignore
│   ├── Dockerfile
│   ├── package-lock.json
│   ├── package.json
│   ├── server.js         # Backend entry point
│   └── upload.js         # Login for handling file uploads
├── client/               #Frontend(React)
│   ├── public/
│   │   ├── favicon.ico
│   │   ├── index.html
│   │   ├── logo192.png
│   │   ├── logo512.png
│   │   ├── manifest.json
│   │   └── robots.txt
│   └── src/
│       ├── components/   #Reusable UI components
│       │   ├── AboutUs.js
│       │   ├── AddProduct.js
│       │   ├── App.js
│       │   ├── EditProductForm.js
│       │   ├── Footer.js
│       │   ├── Header.js
│       │   ├── Navbar.js
│       │   ├── NewProductForm.js
│       │   ├── Product.js
│       │   ├── ProductControl.js
│       │   ├── ProductDetail.js
│       │   ├── ProductList.js
│       │   ├── ReusableForm.js
│       │   └── images/
│       │       ├── backgrounds
│       │       ├── logo
│       │       ├── products
│       │       ├── screenshots
│       │       ├── social_icons
│       │       ├── mouse_click.png
│       │       └──product_image.jpeg
│       │   
│       │    
│       ├── App.css
│       ├── App.test.js
│       ├── index.js
│       ├── product-detail.css
│       ├── serviceWorker.js
│       └── setupTests.js
├── .gitignore
├── Dockerfile
├── package-lock.json
├── README.md
└── roles/
    ├── backend-deployment/
    │   ├── tasks/
    │   │   └── main.yml
    │   └── vars/
    │       └── main.yml
    ├── frontend-deployment/
    │   ├── tasks/
    │   │   └── main.yml
    │   └── vars/
    │       └── main.yml
    ├── setup-mongodb/
    │   └── tasks/
    │       └── main.yml
    └── vars/
        ├── main.yml
        ├── .dockerignore
        ├── .gitignore
        ├── ansible.cfg
        ├── backend-deployment.yaml
        ├── docker-compose.yaml
        ├── explanataion.md
        ├── frontend-deployment.yaml
        ├── hosts
        ├── image.png
        ├── inventory.yml
        ├── playbook.yml
        ├── README.md
        ├── Structure
        └── Vagrantfile
```
---

## ⚙️ Deployment Instructions

Follow these steps to deploy the application for both stages.

### Prerequisites

You need the following tools installed on your local machine:

1.  **Vagrant**
2.  **VirtualBox** 
3.  **Ansible** (required for Stage 1 & 2)
4.  **Terraform** (required for Stage 2)
5.  **Git**
---
### Stage 1: Ansible-Only Deployment

### Clone the Repository

Navigate to your preferred directory and clone the project:

```bash
 git clone https://github.com/SanthaC/yolo
- cd yolo 
```

#### Step 1: Create and Test the Vagrant Environment

This stage uses the `Vagrantfile` to provision the VM and then runs the `playbook.yml` to configure the server and deploy the application.

1.Bring up the virtual machine:

```bash
vagrant up
`````
![Vagrant-up Screenshoot](./client/src/images/screenshots/vagrant-up.png)

2.SSH into it to test:

````bash
vagrant ssh
``````
![Vagrant-ssh Screenshoot](./client/src/images/screenshots/vagrant-ssh.png)

3. Check if ansible can reach it on host:

`````bash
ansible all -i inventory.yml -m ping
`````
✅ If you get a “pong” response, your setup is correct.

![ping Screenshoot](./client/src/images/screenshots/ping-response.png)

### Step 2: Run your Ansible Playbook

From the host machine, in your project root:
```bash
ansible-playbook -i inventory.yml playbook.yml
``````
![Playbook Screenshoot](./client/src/images/screenshots/playbook.png)

This should:

Clone your GitHub code inside the VM.

Build Docker images (for backend, frontend(client), MongoDB).

Run containers via docker-compose.yaml.

Launch your e-commerce site on localhost:port.

Test in your browser ( http://localhost:3000)

![Frontend Output](./client/src/images/screenshots/web-application.png)



### Stage 2: Ansible + Terraform Integration - YOLO E-Commerce App

#### Overview

This stage builds upon Stage 1 by integrating Terraform and Ansible to automate the complete provisioning and configuration of the YOLO e-commerce web application.

The goal is to use Terraform for infrastructure provisioning and Ansible for server configuration and Dockerized application deployment — all triggered with a single command.


#### Repo structure
```
└── Stage_two
    ├── ansible
    │   ├── inventory.ini
    │   ├── playbook.yaml
    │   └── roles
    │       ├── backend-deployment
    │       │   ├── tasks
    │       │   │   └── main.yml
    │       │   └── vars
    │       │       └── main.yml
    │       ├── frontend-deployment
    │       │   ├── tasks
    │       │   │   └── main.yml
    │       │   └── vars
    │       │       └── main.yml
    │       └── setup-mongodb
    └── terraform
        ├── main.tf
        ├── output.tf
        ├── provider.tf
        └── variables.tf

```
---
####⚙️ Key Components

🪴 Terraform

Provisions a virtual environment (e.g., Vagrant VM or EC2 instance).

Uses variables for configuration management (region, instance type)

Outputs the instance IP to be used by Ansible.

🤖 Ansible

Invokes Terraform automatically using the community.general.terraform module.

Installs Docker and creates a shared network app-net.

Deploys three containers:

MongoDB → for data persistence

Backend → API service

Frontend → user interface

####🔧 How to Run

1. Navigate to Stage 2 directory
`````
cd stage_two
`````

2. Initialize Terraform
`````bash
terraform init
`````

3. Run Ansible Playbook
`````bash
ansible-playbook -i inventory/hosts.ini playbook.yml
`````

This will:

Provision the infrastructure via Terraform

Configure the server

Launch the Dockerized YOLO app automatically

Access the App

http://localhost:3000

###🧩 Roles Summary

Role	Description

setup-mongodb	Pulls and runs MongoDB container, ensuring data persistence.
backend-deployment	Builds or pulls backend API container and connects to MongoDB.
frontend-deployment	Builds or pulls frontend container and connects to backend.

###🛡️ Good Practices Implemented

Use of variables for reusability and clarity.

Proper role separation for maintainability.

Tags and blocks used for structured execution.

Terraform–Ansible automation ensures one-step deployment.

### ✅ Expected Outcome

Terraform provisions the server environment.

Ansible configures the environment and runs Docker containers.

The YOLO e-commerce application runs successfully and persists product data.

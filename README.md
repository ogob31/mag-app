# MAG APP
MAG App is flask microservice deployed with Docker, Jenkins, and Terraform.
It illustrates CI/CD best practices with automated testing, and infrastructure-as-code (IaC)

# Project Structure 
mag-app/
├── application/                # Python Flask microservice
│   ├── app.py                  # Main app (health + URL validation)
│   ├── validation.py           # URL validation logic
│   ├── test_validation.py      # Unit tests
│   ├── tests/                  # Additional tests
│   │   └── test_smoke.py       # Smoke/health test
│   ├── Dockerfile              # Container build definition
│   └── requirements.txt        # Python dependencies
│
├── infrastructure/             # Terraform infrastructure
│   ├── main.tf                 # Core resources (EC2, VPC, etc.)
│   ├── security.tf             # Security groups & ingress rules
│   ├── keypair.tf              # SSH key pair management
│   ├── variables.tf            # Input variables
│   ├── outputs.tf              # Outputs (EC2 IP, SSH key path)
│   ├── user_data.sh            # Bootstrap script
│   └── .gitignore              # Ignore sensitive files
│
├── Jenkinsfile                 # CI/CD pipeline definition
└── README.md                   # Documentation

# Features
- Flask API
-Flask microservice with health check and URL validation.

- Testing 
-Unit tests with pytest for validation
-Smoke test for health endpoint

- Containerization
-Dockerfile for building the app container with lightweight image (george524/mag-app)

- CI/CD with Jenkins
-GitHub webhooks triggers builds 
-Stages: checkout-Unit Tests-Build-Test-Push-Deploy
-Pushes to Docker Hub on main branch

- Infrastructure as Code with Terraform
-Provisions VPC, Security Groups, EC2 runner
-Manages SSH keys and outputs
-Automated setup of Jenkins and app host

# Getting Started
1. Clone Repository
git clone https://github.com/ogob31/mag-app.git
cd mag-app

2. Local Build and Run
cd application
docker build -t mag-app:local .
docker run -p 5000:5000 mag-app:local
curl http://localhost:5000/health

3. cd infrastructure
terraform init
terraform apply --auto-approve

Outputs include:
- ec2_public_ip: EC2 instance IP
- ssh_private_key_path: Path to PEM file for SSH access

4. Access Jenkins
Open http://<EC2_public_ip>:8080 in browser

5. Deploy App via Pipeline
Push code to main branch to trigger Jenkins pipeline
Deployed app available at;
http://<EC2_PUBLIC_IP>/health
http://<EC2_PUBLIC_IP>/api/validate-url


-Security Notes
-Sensitive files ignored with .gitignore
-Docker Hub credentials stored securely in Jenkins (docker-hub-creds)
-Security group restricts access to ports 22, 80 and 8080
-SSH key pair managed by Terraform, private key saved locally (not in repo)

# Points to learn
-Infrastructure as Code with Terraform
-CI/CD with Jenkins pipelines
-Containerization with Docker
-Automating the full flow: Code-Test-Image-Deploy


# Cleanup
terraform destroy --auto-approve

# Screenshots

## Jenkins Pipeline
![Jenkins Pipeline](screenshots/jenkins-pipeline.png)

## URL Validation
![URL Validation](screenshots/url-validation.png)

## Health Check
![Health Check](screenshots/health-check.png)


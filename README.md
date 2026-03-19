# 🚀 Production-Grade AWS Architecture with Terraform

## 📌 Overview

This project provisions a production-style AWS infrastructure using **Terraform**.
It deploys highly available, private EC2 instances behind an **Application Load Balancer (ALB)** with **HTTPS termination via AWS ACM**.

The infrastructure is built with security, scalability, and automation principles in mind.


<img width="1800" height="4022" alt="terraform-aws-clean" src="https://github.com/user-attachments/assets/6cc54b58-a78f-40ac-8ea9-d1bb6fde783a" />



---

## 🏗 Architecture Summary

The infrastructure includes:

* **VPC** with public and private subnets across 2 Availability Zones
* **Internet Gateway** for inbound traffic
* **NAT Gateway** for outbound internet access from private subnets
* **Application Load Balancer (ALB)** (internet-facing)
* **ACM SSL Certificate** for HTTPS
* **Auto Scaling Group (ASG)** in private subnets
* **SSM Session Manager** for secure instance access (no SSH exposure)
* **Terraform Remote Backend (S3 + DynamoDB state locking)**

---

## 🌐 End-to-End Flow (DevOps → HTTPS Live App)

```
[ DevOps Engineer ]
          ↓
[ Write Terraform Code ]
          ↓
[ terraform init ]
          ↓
[ terraform plan ]
          ↓
[ terraform apply ]
          ↓
[ Terraform calls AWS APIs ]
          ↓
---------------- INFRA CREATION ----------------
          ↓
[ VPC Created ]
          ↓
[ Public & Private Subnets ]
          ↓
[ Internet Gateway Attached ]
          ↓
[ NAT Gateway (Public Subnet) ]
          ↓
[ Route Tables Configured ]
          ↓
[ Security Groups Created ]
          ↓
[ ACM Certificate Requested ]
          ↓
[ ALB Created (Public Subnet) ]
          ↓
[ Target Group Created ]
          ↓
[ Launch Template Created ]
          ↓
[ Auto Scaling Group Created ]
          ↓
[ EC2 Instances Launched ]
          ↓
[ Nginx Installed (user_data) ]
          ↓
[ EC2 Registered to Target Group ]
          ↓
---------------- SSL + DNS ----------------
          ↓
[ ACM Certificate Validated (DNS) ]
          ↓
[ HTTPS Listener Enabled (443) ]
          ↓
[ DNS → ALB Mapping ]
          ↓
---------------- RUNTIME TRAFFIC ----------------
          ↓
[ User → https://domain.com ]
          ↓
[ Request hits ALB (SSL Termination) ]
          ↓
[ ALB → Target Group ]
          ↓
[ Traffic → EC2 (Private Subnet) ]
          ↓
[ Nginx Responds ]
          ↓
[ Response → User ]

```

---

## 🔐 Security Design Decisions

### 1️⃣ Private EC2 Instances

Application servers are deployed in **private subnets** to prevent direct internet exposure.

### 2️⃣ No SSH Access

No port 22 is exposed. Access is managed using **AWS SSM Session Manager**, reducing attack surface.

### 3️⃣ SSL Termination at ALB

HTTPS is terminated at the ALB using **ACM-managed certificates**, centralizing certificate management.

### 4️⃣ Controlled Inbound Rules

* ALB Security Group allows ports 80 and 443 from the internet.
* EC2 Security Group allows traffic only from ALB Security Group.

---

## 📈 High Availability & Scaling

* Multi-AZ deployment (2 Availability Zones)
* Auto Scaling Group maintains minimum desired capacity
* ALB performs health checks
* Failed instances are automatically replaced

---

## 🧱 Terraform Structure

```
production-aws-architecture/
│
├── terraform/
│   ├── acm.tf
│   ├── alb.tf
│   ├── asg.tf
│   ├── backend.tf
│   ├── iam.tf
│   ├── launch_template.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── provider.tf
│   └── security.tf
│
├── README.md
└── architecture-diagram.png
```

---

## 🗂 Remote State Management

Terraform state is stored remotely using:

* **S3 Bucket** (state storage)
* **DynamoDB Table** (state locking)

This prevents concurrent state corruption.

## 🗂 Terraform Remote Backend Setup (Required)

This project uses an S3 backend with DynamoDB state locking.

Before running Terraform, create the following resources manually:

### 1️⃣ S3 Bucket (Remote State Storage)

* Region: `ap-south-1`
* Versioning: Enabled
* Block Public Access: Enabled

Example name:

```
my-terraform-state-bucket
```
---

### 2️⃣ DynamoDB Table (State Locking)

* Table name: `terraform-locks`
* Partition key: `LockID` (String)
* Billing mode: On-demand

---

### 3️⃣ Update backend.tf

Update the backend configuration in `backend.tf`:

```
terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    key            = "production-architecture/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

---
## 🚀 Deployment

### 1️⃣ Clone Repository

git clone https://github.com/koushikbijili/aws-production-infrastructure-terraform.git
cd aws-production-infrastructure-terraform
cd terraform

### 2️⃣ Configure Remote Backend

Update backend.tf with your S3 bucket and DynamoDB table.

### 3️⃣ Initialize Terraform

terraform init

### 4️⃣ Review Execution Plan

terraform plan

### 5️⃣ Apply Infrastructure

terraform apply


### Access Application

After deployment, retrieve the ALB DNS:

```
terraform output alb_dns_name
```

Example:

```
https://example.com
```

---

## 🧪 Testing

* Confirm ALB listener on ports 80 and 443
<img width="1912" height="793" alt="Screenshot 2026-02-10 153919" src="https://github.com/user-attachments/assets/2af64887-dcc8-459b-92a5-372a3670a567" />

* Verify HTTP redirects to HTTPS
<img width="804" height="310" alt="Screenshot 2026-02-10 125445" src="https://github.com/user-attachments/assets/4a0e8e9c-c155-4a84-95b9-7a8fc0c6c24b" />

* Validate Target Group health status
<img width="1443" height="557" alt="Screenshot 2026-02-10 153753" src="https://github.com/user-attachments/assets/7048da77-ce31-4b12-b241-acafb11114d0" />

* Confirm EC2 access via SSM
<img width="1918" height="762" alt="Screenshot 2026-02-10 154142" src="https://github.com/user-attachments/assets/fc2b7cf2-2d1e-4e41-9cc3-a2adfeb46d1a" />


---

## 💰 Cost Awareness

This infrastructure includes:

* NAT Gateway
* Application Load Balancer
* EC2 Instances

Destroy resources after testing:

```
terraform destroy
```

---

## 📚 Key Learnings

* Production-grade VPC design
* Multi-AZ architecture
* ALB integration with ASG
* ACM certificate management
* Secure access using SSM
* Remote state locking in Terraform

---

# 🔥 Now Important — Update ACM in Code

Inside `acm.tf`, change:

```
domain_name = "example.com"
subject_alternative_names = ["www.example.com"]
```

Instead of your real domain.

```
# Replace example.com with your own domain
```


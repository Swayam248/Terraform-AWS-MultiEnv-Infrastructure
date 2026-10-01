# Terraform AWS Multi-Environment Infrastructure

A practical Terraform project that provisions AWS infrastructure using **Infrastructure as Code (IaC)** and demonstrates Terraform fundamentals through separate **Dev, Staging, and Production** environments.

The project covers AWS networking, EC2, reusable Terraform modules, variables, locals, data sources, outputs, separate Terraform state, S3 remote state, state locking, security scanning with Checkov, and GitHub Actions CI.

---

# 1. Project Overview

This project demonstrates how Terraform can be used to create and manage AWS infrastructure in a structured, reusable, and version-controlled way.

The project includes:

* AWS VPC
* Public subnet
* Private subnet
* Internet Gateway
* Public route table
* Route table association
* Security Group
* AWS EC2 instances
* AWS Key Pair
* Ubuntu AMI data source
* Reusable EC2 Terraform module
* Dev environment
* Staging environment
* Production environment
* Separate Terraform state for each environment
* Amazon S3 remote state
* S3-native state locking
* Terraform variables
* Terraform locals
* Terraform outputs
* Terraform data sources
* `count`
* `for_each`
* `depends_on`
* `lifecycle`
* Checkov security scanning
* IMDSv2 configuration
* GitHub Actions CI

The project intentionally avoids unnecessary complexity such as:

* ECS
* EKS
* RDS
* Load Balancers
* NAT Gateways
* Complex multi-tier networking
* Large deployment pipelines

The goal is to demonstrate **strong Terraform fundamentals and practical AWS knowledge** without making the project unnecessarily large.

---

# 2. What We Are Building

The final architecture looks like:

```text
                         Internet
                            |
                            |
                    Internet Gateway
                            |
                            |
                    Public Route Table
                            |
                 -----------------------
                 |                     |
           Public Subnet          Private Subnet
           10.0.1.0/24            10.0.2.0/24
                 |
                 |
          Security Group
                 |
        ---------------------
        |         |         |
      DEV      STAGING     PROD
       EC2        EC2        EC2
```

Terraform manages the shared AWS networking infrastructure from the root configuration.

The EC2 instances are managed by separate environment configurations:

```text
environments/dev
environments/staging
environments/prod
```

All environments reuse the same EC2 module:

```text
modules/ec2
```

Terraform state is stored remotely in Amazon S3.

---

# 3. Why Terraform?

Without Infrastructure as Code, infrastructure can be created manually through the AWS Console:

```text
AWS Console
    ↓
Create VPC
    ↓
Create subnet
    ↓
Create route table
    ↓
Create security group
    ↓
Create EC2
    ↓
Repeat for other environments
```

This becomes difficult to reproduce and maintain.

With Terraform:

```text
Terraform Configuration
        ↓
terraform plan
        ↓
Review changes
        ↓
terraform apply
        ↓
AWS Infrastructure
```

Terraform allows infrastructure to be:

* Reproducible
* Version controlled
* Reviewable
* Automated
* Consistent
* Reusable

---

# 4. Terraform Architecture

Terraform works using three important components:

```text
Terraform Configuration
        ↓
Terraform State
        ↓
Actual AWS Infrastructure
```

## Terraform Configuration

The `.tf` files describe the desired infrastructure.

Example:

```hcl
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
}
```

This tells Terraform:

> Create and manage a VPC with this CIDR block.

## Terraform State

Terraform state is Terraform's record of the infrastructure it manages.

For example:

```text
aws_vpc.main
     ↓
vpc-xxxxxxxx
```

State maintains the mapping between Terraform resources and real AWS resources.

## AWS

AWS contains the actual infrastructure.

Terraform compares the configuration, state, and actual infrastructure to determine what changes are required.

---

# 5. Prerequisites

Before starting, install and configure the following:

* Terraform
* AWS CLI
* Git
* GitHub account
* VS Code
* Python
* Checkov

This project was developed using **Windows and PowerShell**.

---

# 5.1 Terraform Installation

Download Terraform from the official HashiCorp website:

https://developer.hashicorp.com/terraform/install

Install Terraform and make sure it is available in the system PATH.

Open PowerShell and verify:

```powershell
terraform version
```

You should see output similar to:

```text
Terraform v1.x.x
```

---

# 5.2 AWS CLI Installation

The AWS CLI is used to communicate with AWS from the command line.

It is also used to verify AWS authentication and perform certain AWS-related project operations.

## Windows Installation

Download the AWS CLI installer from the official AWS documentation:

https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

Download the Windows `.msi` installer.

Run the installer and follow the installation wizard.

After installation, **close and reopen PowerShell** so that the updated PATH is loaded.

Verify the installation:

```powershell
aws --version
```

Expected output will look similar to:

```text
aws-cli/2.x.x Python/3.x.x Windows/11 exe/AMD64
```

The exact version will depend on the installed AWS CLI version.

---

## Configure AWS CLI

Run:

```powershell
aws configure
```

AWS CLI will ask for:

```text
AWS Access Key ID [None]:
AWS Secret Access Key [None]:
Default region name [None]:
Default output format [None]:
```

For this project, use:

```text
Default region name: ap-south-1
Default output format: json
```

The credentials should belong to an AWS IAM identity with the permissions required to create and manage the resources used by this project.

---

## Verify AWS Authentication

Run:

```powershell
aws sts get-caller-identity
```

A successful response will look similar to:

```json
{
    "UserId": "...",
    "Account": "...",
    "Arn": "arn:aws:iam::...:user/..."
}
```

This confirms that the AWS CLI is authenticated and communicating with AWS successfully.

### Important Security Note

Never commit AWS credentials to GitHub.

Do not put AWS access keys or secret keys inside:

```text
*.tf
*.tfvars
README.md
GitHub source files
```

AWS credentials should remain outside the Git repository.

---

# 5.3 Git Installation

Install Git for Windows:

https://git-scm.com/download/win

Verify:

```powershell
git --version
```

---

# 5.4 GitHub

Create a GitHub account if you don't already have one.

Create a repository for this project.

Example:

```text
Terraform-AWS-MultiEnv-Infrastructure
```

GitHub will be used for:

* Source control
* Project history
* Collaboration
* GitHub Actions CI

---

# 5.5 VS Code

Install Visual Studio Code:

https://code.visualstudio.com/

Open the project directory in VS Code.

The Terraform extension can also be installed from the VS Code Extensions marketplace.

---

# 5.6 Python and Checkov

Checkov is used to scan Terraform configurations for security issues.

Install Checkov:

```powershell
pip install checkov
```

Verify the installation:

```powershell
python -m pip show checkov
```

If the `checkov` command is not available directly on Windows, locate the Checkov script directory and run the `.cmd` file.

Example:

```powershell
& "$env:APPDATA\Python\Python313\Scripts\checkov.cmd" --version
```

The Python version/path may differ depending on your installation.

---

# 6. Create the Project

Create the project directory:

```powershell
mkdir Terraform-AWS-MultiEnv-Infrastructure
cd Terraform-AWS-MultiEnv-Infrastructure
```

Initialize Git:

```powershell
git init
```

Add the GitHub remote:

```powershell
git remote add origin <YOUR_GITHUB_REPOSITORY_URL>
```

Verify:

```powershell
git remote -v
```

---

# 7. Final Project Structure

The final project structure is:

```text
Terraform-AWS-MultiEnv-Infrastructure
│
├── .github
│   └── workflows
│       └── terraform.yml
│
├── environments
│   ├── dev
│   │   ├── backend.tf
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   ├── terraform.tfvars
│   │   ├── variables.tf
│   │   └── .terraform.lock.hcl
│   │
│   ├── staging
│   │   ├── backend.tf
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   ├── terraform.tfvars
│   │   ├── variables.tf
│   │   └── .terraform.lock.hcl
│   │
│   └── prod
│       ├── backend.tf
│       ├── main.tf
│       ├── outputs.tf
│       ├── terraform.tfvars
│       ├── variables.tf
│       └── .terraform.lock.hcl
│
├── modules
│   └── ec2
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
│
├── backend.tf
├── data.tf
├── key-pair.tf
├── locals.tf
├── main.tf
├── outputs.tf
├── security-group.tf
├── variables.tf
├── terraform.tfvars
├── .gitignore
└── .terraform.lock.hcl
```

---

# 8. Terraform File Organization

Terraform automatically loads all `.tf` files in the current directory.

For example:

```text
main.tf
variables.tf
outputs.tf
locals.tf
data.tf
```

Terraform treats them as one configuration.

We separate files to keep the project organized.

Typical responsibilities:

| File                | Purpose                     |
| ------------------- | --------------------------- |
| `main.tf`           | Provider and core resources |
| `variables.tf`      | Input variables             |
| `terraform.tfvars`  | Variable values             |
| `locals.tf`         | Reusable local values       |
| `data.tf`           | Data sources                |
| `outputs.tf`        | Output values               |
| `security-group.tf` | Security Group              |
| `key-pair.tf`       | AWS Key Pair                |
| `backend.tf`        | Remote state configuration  |

---

# 9. AWS Provider

The AWS provider allows Terraform to communicate with AWS APIs.

Example:

```hcl
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
```

The provider determines which platform Terraform will manage.

---

# 10. Terraform Variables

Create `variables.tf`:

```hcl
variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "ap-south-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}
```

Variables allow configuration values to be separated from resource definitions.

Instead of hardcoding:

```hcl
region = "ap-south-1"
```

we use:

```hcl
region = var.aws_region
```

---

# 11. terraform.tfvars

Create:

```text
terraform.tfvars
```

Example:

```hcl
aws_region = "ap-south-1"
vpc_cidr   = "10.0.0.0/16"
```

Terraform automatically loads values from `terraform.tfvars`.

Because `.tfvars` files may contain sensitive or machine-specific information, this project ignores them in Git.

---

# 12. Local Values

Create `locals.tf`:

```hcl
locals {
  project_name = "terraform-multienv"
}
```

A local value allows the same value to be reused.

Example:

```hcl
Name = "${local.project_name}-vpc"
```

Instead of repeatedly writing:

```text
terraform-multienv
```

---

# 13. Create the VPC

In `main.tf`:

```hcl
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "${local.project_name}-vpc"
  }
}
```

The project uses:

```text
10.0.0.0/16
```

The VPC provides the overall network.

---

# 14. Initialize Terraform

Run this from the **project root**:

```powershell
terraform init
```

`terraform init`:

* Downloads providers
* Initializes Terraform
* Creates `.terraform/`
* Creates or updates `.terraform.lock.hcl`
* Initializes the configured backend

The `.terraform/` directory should not be committed.

The `.terraform.lock.hcl` file should be committed.

---

# 15. Format Terraform

From the project root:

```powershell
terraform fmt -recursive
```

To check formatting without changing files:

```powershell
terraform fmt -check -recursive
```

---

# 16. Validate Terraform

Run:

```powershell
terraform validate
```

Expected:

```text
Success! The configuration is valid.
```

Validation checks whether the configuration is syntactically and structurally valid.

---

# 17. Terraform Plan

Run:

```powershell
terraform plan
```

Terraform calculates what changes it would make.

Plan symbols:

```text
+   create
~   update
-   destroy
-/+ replace
```

Always inspect the plan before applying.

---

# 18. Terraform Apply

If the plan is correct:

```powershell
terraform apply
```

Terraform asks for confirmation.

Enter:

```text
yes
```

Terraform then creates or updates the infrastructure.

---

# 19. Availability Zones Data Source

Create `data.tf`:

```hcl
data "aws_availability_zones" "available" {
  state = "available"
}
```

A data source reads existing information.

It does not create the resource.

Conceptually:

```text
resource
    ↓
creates/manages infrastructure

data
    ↓
reads existing information
```

The Availability Zone data source is used when creating subnets.

---

# 20. Outputs

Create `outputs.tf`:

```hcl
output "vpc_id" {
  description = "ID of the Terraform-managed VPC"
  value       = aws_vpc.main.id
}

output "availability_zones" {
  description = "Available AWS Availability Zones"
  value       = data.aws_availability_zones.available.names
}
```

Outputs expose useful values.

Run:

```powershell
terraform output
```

---

# 21. Public Subnet

Create:

```hcl
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "${local.project_name}-public-subnet"
  }
}
```

Public subnet:

```text
10.0.1.0/24
```

---

# 22. Private Subnet

Create:

```hcl
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "${local.project_name}-private-subnet"
  }
}
```

Private subnet:

```text
10.0.2.0/24
```

There is intentionally no public route table association for this subnet.

---

# 23. Public vs Private Subnet

A subnet is not simply public because it has a public IP.

Routing is the important concept.

## Public subnet

The public subnet has a route:

```text
0.0.0.0/0
      ↓
Internet Gateway
```

Resources can therefore have internet connectivity when appropriately configured.

## Private subnet

The private subnet does not have a route to the Internet Gateway.

Therefore it does not have direct internet connectivity.

This project does not create a NAT Gateway because it is unnecessary for the learning objective and introduces additional AWS cost.

---

# 24. Internet Gateway

Create:

```hcl
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.project_name}-igw"
  }
}
```

The Internet Gateway provides the path between the VPC and the internet.

---

# 25. Public Route Table

Create:

```hcl
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${local.project_name}-public-rt"
  }
}
```

The route:

```text
0.0.0.0/0
      ↓
Internet Gateway
```

means traffic to destinations not matched by a more specific route is sent through the Internet Gateway.

---

# 26. Route Table Association

Create:

```hcl
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
```

This associates the public subnet with the public route table.

Network flow:

```text
EC2
 ↓
Public Subnet
 ↓
Public Route Table
 ↓
Internet Gateway
 ↓
Internet
```

---

# 27. Security Group

Create `security-group.tf`:

```hcl
resource "aws_security_group" "web" {
  name        = "${local.project_name}-web-sg"
  description = "Security group for web servers"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.project_name}-web-sg"
  }
}
```

Ports:

```text
22 → SSH
80 → HTTP
```

For production infrastructure, SSH should normally be restricted to trusted source IP addresses rather than:

```text
0.0.0.0/0
```

The open SSH rule is intentionally simplified for this learning project.

---

# 28. SSH Key Pair

Generate an Ed25519 SSH key:

```powershell
ssh-keygen -t ed25519 -f "$env:USERPROFILE\.ssh\terraform-ec2" -C "terraform-ec2"
```

This creates:

```text
terraform-ec2
terraform-ec2.pub
```

The private key:

```text
terraform-ec2
```

must never be committed or shared.

The public key:

```text
terraform-ec2.pub
```

is provided to AWS.

Get the public key:

```powershell
Get-Content "$env:USERPROFILE\.ssh\terraform-ec2.pub"
```

An Ed25519 public key looks similar to:

```text
ssh-ed25519 AAAAC3... user@machine
```

Copy the entire public-key line when configuring Terraform.

---

# 29. Terraform SSH Key Variable

The project uses a Terraform variable instead of a machine-specific Windows path.

In the root `variables.tf`:

```hcl
variable "ec2_public_key" {
  description = "SSH public key used for EC2 access"
  type        = string
  sensitive   = true
}
```

In the local `terraform.tfvars`:

```hcl
ec2_public_key = "YOUR_PUBLIC_KEY"
```

Do not commit `terraform.tfvars`.

---

# 30. AWS Key Pair Resource

Create `key-pair.tf`:

```hcl
resource "aws_key_pair" "ec2" {
  key_name   = "${local.project_name}-ec2-key"
  public_key = var.ec2_public_key
}
```

Terraform uploads the public key to AWS.

The private key stays on the local computer.

---

# 31. EC2 Module

Instead of defining EC2 three times, create a reusable module:

```text
modules/ec2/
├── main.tf
├── variables.tf
└── outputs.tf
```

The module contains reusable EC2 logic.

---

# 32. Module Variables

`modules/ec2/variables.tf`:

```hcl
variable "ami_id" {
  description = "AMI ID to use for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "subnet_id" {
  description = "Subnet where the EC2 instance will be launched"
  type        = string
}

variable "security_group_id" {
  description = "Security group to attach to the EC2 instance"
  type        = string
}

variable "key_name" {
  description = "AWS key pair name for SSH access"
  type        = string
}

variable "associate_public_ip_address" {
  description = "Whether to associate a public IP address"
  type        = bool
  default     = false
}

variable "name" {
  description = "Name tag for the EC2 instance"
  type        = string
}
```

These variables make the module reusable.

---

# 33. Module EC2 Resource

`modules/ec2/main.tf`:

```hcl
resource "aws_instance" "this" {
  ami           = var.ami_id
  instance_type = var.instance_type

  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = var.key_name

  associate_public_ip_address = var.associate_public_ip_address

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name = var.name
  }
}
```

The `metadata_options` block requires IMDSv2:

```hcl
http_tokens = "required"
```

This was added as part of the security hardening work.

---

# 34. Module Outputs

`modules/ec2/outputs.tf`:

```hcl
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.this.id
}

output "public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.this.public_ip
}

output "private_ip" {
  description = "Private IP of the EC2 instance"
  value       = aws_instance.this.private_ip
}

output "public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.this.public_dns
}
```

Parent environments can use:

```hcl
module.ec2.instance_id
```

and:

```hcl
module.ec2.public_ip
```

---

# 35. Why Use a Module?

Without a module:

```text
Dev EC2 configuration
Staging EC2 configuration
Prod EC2 configuration
```

would contain duplicated code.

With a module:

```text
                EC2 Module
                    |
        -------------------------
        |           |           |
       Dev       Staging       Prod
```

The module contains reusable logic while each environment supplies its own values.

---

# 36. Environment Structure

The project has three environments:

```text
environments/
├── dev/
├── staging/
└── prod/
```

Each environment has:

* Its own Terraform configuration
* Its own Terraform state
* Its own variables
* Its own outputs
* Its own backend configuration

---

# 37. Dev Environment

Directory:

```text
environments/dev/
```

`variables.tf`:

```hcl
variable "aws_region" {
  description = "AWS region for the Dev environment"
  type        = string
  default     = "ap-south-1"
}

variable "instance_type" {
  description = "EC2 instance type for Dev"
  type        = string
  default     = "t3.micro"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}
```

`terraform.tfvars`:

```hcl
aws_region    = "ap-south-1"
instance_type = "t3.micro"
environment   = "dev"
```

---

# 38. Dev Data Sources

Dev does not create another VPC.

It reads the shared VPC:

```hcl
data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["terraform-multienv-vpc"]
  }
}
```

It also reads:

* Public subnet
* Security Group
* Key Pair
* Ubuntu AMI

This demonstrates how separate Terraform configurations can consume existing infrastructure.

---

# 39. Dev EC2 Module

Dev calls the reusable module:

```hcl
module "ec2" {
  source = "../../modules/ec2"

  ami_id                      = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnet.public.id
  security_group_id           = data.aws_security_group.web.id
  key_name                    = data.aws_key_pair.ec2.key_name
  associate_public_ip_address = true
  name                        = "terraform-multienv-${var.environment}-web"
}
```

The module source:

```text
../../modules/ec2
```

points to the reusable EC2 module.

---

# 40. Staging and Production

Staging and Production use the same architecture.

The environment variable changes:

```text
staging
```

or:

```text
prod
```

Therefore EC2 names become:

```text
terraform-multienv-staging-web
terraform-multienv-prod-web
```

The same module is reused across all environments.

---

# 41. Why Separate Environment State?

Each environment has its own Terraform state:

```text
Dev
 ↓
dev state

Staging
 ↓
staging state

Prod
 ↓
prod state
```

This provides environment isolation.

A Dev Terraform operation does not directly operate on resources managed by the Production state.

It also makes environment-specific access control easier.

---

# 42. Terraform State

Terraform state is Terraform's record of the infrastructure it manages.

Example:

```text
module.ec2.aws_instance.this
        ↓
i-xxxxxxxx
```

Terraform uses state during:

```text
terraform plan
terraform apply
terraform destroy
```

State is therefore a critical part of Terraform.

---

# 43. Local vs Remote State

A local state file looks like:

```text
terraform.tfstate
```

Local state becomes difficult for teams because each developer may have a different copy.

Remote state centralizes the state.

This project uses Amazon S3.

---

# 44. S3 Remote State

The project uses an S3 bucket for remote Terraform state.

The bucket should have:

* Versioning enabled
* Encryption enabled
* Public access blocked
* State locking enabled

The project uses:

```text
S3 bucket
terraform-multienv-state-swayam
```

Region:

```text
ap-south-1
```

When recreating this project, use your own globally unique S3 bucket name.

---

# 45. Root Backend

Create `backend.tf`:

```hcl
terraform {
  backend "s3" {
    bucket       = "terraform-multienv-state-swayam"
    key          = "root/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}
```

Important properties:

```text
bucket
    ↓
S3 bucket

key
    ↓
State file location

encrypt
    ↓
Encryption at rest

use_lockfile
    ↓
State locking
```

---

# 46. Environment Backends

Dev:

```hcl
terraform {
  backend "s3" {
    bucket       = "terraform-multienv-state-swayam"
    key          = "environments/dev/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}
```

Staging:

```hcl
terraform {
  backend "s3" {
    bucket       = "terraform-multienv-state-swayam"
    key          = "environments/staging/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}
```

Production:

```hcl
terraform {
  backend "s3" {
    bucket       = "terraform-multienv-state-swayam"
    key          = "environments/prod/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}
```

---

# 47. Initialize the Remote Backend

From the project root:

```powershell
terraform init -migrate-state
```

For Dev:

```powershell
cd environments\dev
terraform init -migrate-state
```

For Staging:

```powershell
cd ..\staging
terraform init -migrate-state
```

For Production:

```powershell
cd ..\prod
terraform init -migrate-state
```

Terraform migrates existing local state into the configured remote backend.

---

# 48. Verify S3 State

From the project root:

```powershell
aws s3 ls s3://terraform-multienv-state-swayam --recursive
```

Expected structure:

```text
environments/dev/terraform.tfstate
environments/staging/terraform.tfstate
environments/prod/terraform.tfstate
root/terraform.tfstate
```

---

# 49. State Locking

State locking prevents multiple Terraform operations from modifying the same state simultaneously.

Conceptually:

```text
Developer A
    |
terraform apply
    |
State Lock
    |
State

Developer B
    |
terraform apply
    |
Waits while state is locked
```

This project uses:

```hcl
use_lockfile = true
```

for S3-native locking.

---

# 50. Terraform Dependencies

Terraform automatically creates dependencies when resources reference each other.

Example:

```hcl
resource "aws_subnet" "public" {
  vpc_id = aws_vpc.main.id
}
```

Terraform understands:

```text
VPC
 ↓
Subnet
```

This is an implicit dependency.

---

# 51. depends_on

`depends_on` creates an explicit dependency.

Example:

```hcl
resource "aws_instance" "web" {
  # configuration

  depends_on = [
    aws_internet_gateway.main
  ]
}
```

Normally, implicit dependencies are preferred.

Use `depends_on` when Terraform cannot determine a real dependency from resource references.

---

# 52. lifecycle

Terraform supports lifecycle rules.

## create_before_destroy

```hcl
lifecycle {
  create_before_destroy = true
}
```

Terraform attempts to create the replacement before destroying the old resource.

## prevent_destroy

```hcl
lifecycle {
  prevent_destroy = true
}
```

Prevents Terraform from destroying the resource.

## ignore_changes

```hcl
lifecycle {
  ignore_changes = [
    tags
  ]
}
```

Terraform ignores changes to the specified attribute.

These lifecycle concepts were studied as part of the project; they are not required on every resource.

---

# 53. count

`count` can create multiple instances of a resource or module.

Example:

```hcl
module "ec2" {
  count = 2

  source = "../../modules/ec2"

  # configuration
}
```

Resources become:

```text
module.ec2[0]
module.ec2[1]
```

We demonstrated `count` during the project without applying the resulting destructive plan.

Important lesson:

Adding `count` to an existing uncounted resource changes its Terraform address.

That can cause Terraform to propose destroy/create operations unless state is migrated appropriately.

---

# 54. for_each

`for_each` creates instances using keys.

Example:

```hcl
module "ec2" {
  for_each = {
    staging = "t3.micro"
  }

  source = "../../modules/ec2"

  instance_type = each.value

  # other configuration
}
```

The address becomes:

```text
module.ec2["staging"]
```

Comparison:

```text
count
    ↓
numeric indexes

for_each
    ↓
named keys
```

`for_each` is useful when individual instances need meaningful identifiers.

---

# 55. Terraform State Addresses

Examples:

```text
aws_vpc.main

aws_subnet.public

module.ec2.aws_instance.this

module.ec2[0].aws_instance.this

module.ec2["staging"].aws_instance.this
```

Understanding resource addresses is important when working with:

* Modules
* `count`
* `for_each`
* Terraform state
* State migration

---

# 56. State Migration

During development, EC2 management was moved from the root configuration into the Dev environment without destroying the existing EC2.

Terraform state was moved using:

```powershell
terraform state mv -state-out="environments/dev/terraform.tfstate" module.ec2.aws_instance.this module.ec2.aws_instance.this
```

The purpose was to tell Terraform:

> This is the same AWS resource, but it is now managed by another Terraform state.

This avoided unnecessary EC2 recreation.

---

# 57. Ubuntu AMI Data Source

The environments dynamically locate an Ubuntu AMI.

Example:

```hcl
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}
```

This avoids hardcoding an AMI ID.

---

# 58. EC2 Configuration

The reusable module creates:

```text
EC2
Ubuntu AMI
t3.micro
Public subnet
Security Group
SSH key
Public IP
IMDSv2
```

The environment provides the configuration values.

---

# 59. SSH Into EC2

Get the current public IP:

```powershell
terraform output public_ip
```

Then connect:

```powershell
ssh -i "$env:USERPROFILE\.ssh\terraform-ec2" ubuntu@<PUBLIC_IP>
```

For example:

```powershell
ssh -i "$env:USERPROFILE\.ssh\terraform-ec2" ubuntu@13.x.x.x
```

The private SSH key must remain private.

---

# 60. EC2 Network Flow

When connecting to EC2:

```text
Your Computer
      |
      | TCP 22
      ↓
Internet
      |
      ↓
Internet Gateway
      |
      ↓
Public Route Table
      |
      ↓
Public Subnet
      |
      ↓
Security Group
      |
      ↓
EC2
```

The Security Group allows TCP port 22.

---

# 61. EC2 Public IP Behavior

An automatically assigned EC2 public IPv4 address can change after stopping and starting an instance.

Always check the current IP:

```powershell
terraform output public_ip
```

Do not assume an old public IP remains permanently assigned.

---

# 62. Checkov Security Scanning

Checkov scans Terraform configurations for security best practices.

From the project root:

```powershell
& "$env:APPDATA\Python\Python313\Scripts\checkov.cmd" -d .
```

The scan identified multiple findings.

One important security improvement implemented was requiring IMDSv2:

```hcl
metadata_options {
  http_endpoint = "enabled"
  http_tokens   = "required"
}
```

---

# 63. Checkov Findings and Project Scope

Not every Checkov finding was changed.

Some findings were intentionally retained because the project is a learning-focused infrastructure project.

Examples include:

* Public IP required for direct SSH access
* SSH open to the internet for simplified learning access
* Public HTTP access
* Broad outbound traffic
* No NAT Gateway
* No VPC Flow Logs
* No EC2 IAM role
* Other production-hardening recommendations

The purpose of Checkov in this project is to:

1. Scan the configuration.
2. Identify potential security issues.
3. Understand the recommendation.
4. Decide whether it is relevant to the project's scope.
5. Fix meaningful findings where appropriate.

For production infrastructure, these decisions should be reviewed according to the actual security requirements.

---

# 64. GitHub Actions CI

The project includes:

```text
.github/workflows/terraform.yml
```

The workflow runs when code is:

* Pushed to `main`
* Submitted as a pull request to `main`

The workflow performs:

```text
Checkout repository
        ↓
Setup Terraform
        ↓
terraform fmt -check -recursive
        ↓
terraform init -backend=false
        ↓
terraform validate
```

---

# 65. GitHub Actions Workflow

The workflow:

```yaml
name: Terraform CI

on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main

jobs:
  terraform:
    name: Terraform Checks
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3

      - name: Terraform Format Check
        run: terraform fmt -check -recursive

      - name: Terraform Init
        run: terraform init -backend=false

      - name: Terraform Validate
        env:
          TF_VAR_ec2_public_key: "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIci-validation-placeholder"
        run: terraform validate
```

---

# 66. Why `terraform init -backend=false` in CI?

The basic CI pipeline performs configuration checks.

It does not need to access the S3 remote state.

Therefore:

```powershell
terraform init -backend=false
```

initializes Terraform without connecting to the remote backend.

This allows formatting and validation without requiring AWS credentials.

A production-grade CI plan workflow would require authenticated AWS access and appropriate IAM permissions.

---

# 67. Git Workflow

Check status:

```powershell
git status
```

Stage files:

```powershell
git add .
```

Commit:

```powershell
git commit -m "Build Terraform multi-environment AWS infrastructure"
```

Push:

```powershell
git push origin main
```

---

# 68. .gitignore

The project uses:

```gitignore
# Terraform
.terraform/
*.tfstate
*.tfstate.*
*.tfplan

# Terraform crash logs
crash.log
crash.*.log

# Variable files that may contain secrets
*.tfvars
*.tfvars.json

# Local override files
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# Terraform CLI configuration
.terraformrc
terraform.rc
```

Important:

`.terraform.lock.hcl` should **not** be ignored.

It should be committed.

---

# 69. Why Ignore Terraform State?

Terraform state can contain sensitive infrastructure information.

Therefore the project does not commit state files to Git.

Git contains:

```text
Terraform configuration
```

S3 contains:

```text
Terraform state
```

---

# 70. Complete Terraform Workflow

The normal workflow is:

```text
Write Terraform configuration
          ↓
terraform fmt
          ↓
terraform init
          ↓
terraform validate
          ↓
terraform plan
          ↓
Review plan
          ↓
terraform apply
          ↓
AWS infrastructure
```

When modifying infrastructure:

```text
Modify .tf
    ↓
terraform fmt
    ↓
terraform validate
    ↓
terraform plan
    ↓
Review
    ↓
terraform apply
```

---

# 71. Root Commands

Run from:

```text
Terraform-AWS-MultiEnv-Infrastructure
```

Format:

```powershell
terraform fmt -recursive
```

Check formatting:

```powershell
terraform fmt -check -recursive
```

Initialize:

```powershell
terraform init
```

Validate:

```powershell
terraform validate
```

Plan:

```powershell
terraform plan
```

Apply:

```powershell
terraform apply
```

Show state:

```powershell
terraform state list
```

Show outputs:

```powershell
terraform output
```

---

# 72. Dev Commands

From the project root:

```powershell
cd environments\dev
```

Initialize:

```powershell
terraform init
```

Validate:

```powershell
terraform validate
```

Plan:

```powershell
terraform plan
```

Apply:

```powershell
terraform apply
```

Show state:

```powershell
terraform state list
```

Show outputs:

```powershell
terraform output
```

---

# 73. Staging Commands

From the project root:

```powershell
cd environments\staging
```

Initialize:

```powershell
terraform init
```

Validate:

```powershell
terraform validate
```

Plan:

```powershell
terraform plan
```

Apply:

```powershell
terraform apply
```

---

# 74. Production Commands

From the project root:

```powershell
cd environments\prod
```

Initialize:

```powershell
terraform init
```

Validate:

```powershell
terraform validate
```

Plan:

```powershell
terraform plan
```

Apply:

```powershell
terraform apply
```

Production changes should always be reviewed carefully before applying.

---

# 75. Complete Fresh Setup

Someone following this project from scratch should follow this sequence.

## Step 1 — Install tools

Install:

```text
Terraform
AWS CLI
Git
VS Code
Python
Checkov
```

---

## Step 2 — Configure AWS

Verify AWS CLI:

```powershell
aws --version
```

Configure:

```powershell
aws configure
```

Verify:

```powershell
aws sts get-caller-identity
```

---

## Step 3 — Create the repository

Create the GitHub repository and clone it:

```powershell
git clone <YOUR_GITHUB_REPOSITORY_URL>
cd Terraform-AWS-MultiEnv-Infrastructure
```

---

## Step 4 — Create SSH key

```powershell
ssh-keygen -t ed25519 -f "$env:USERPROFILE\.ssh\terraform-ec2" -C "terraform-ec2"
```

Read the public key:

```powershell
Get-Content "$env:USERPROFILE\.ssh\terraform-ec2.pub"
```

---

## Step 5 — Create local variables

Create `terraform.tfvars`:

```hcl
aws_region     = "ap-south-1"
vpc_cidr       = "10.0.0.0/16"
ec2_public_key = "YOUR_PUBLIC_KEY"
```

Do not commit this file.

---

# 76. Create the S3 Backend Bucket

Before using the remote backend, create an S3 bucket.

Use a globally unique name, for example:

```text
terraform-multienv-state-<unique-name>
```

Enable:

```text
Versioning
Server-side encryption
Block public access
```

Use your bucket name in:

```text
backend.tf
```

and all environment backend files.

Example:

```hcl
terraform {
  backend "s3" {
    bucket       = "YOUR-STATE-BUCKET"
    key          = "root/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}
```

---

# 77. Initialize Root

From the project root:

```powershell
terraform init
```

If migrating existing state:

```powershell
terraform init -migrate-state
```

---

# 78. Create Shared Infrastructure

From the project root:

```powershell
terraform fmt -recursive
terraform validate
terraform plan
```

Review the plan.

Then:

```powershell
terraform apply
```

The root state manages:

```text
VPC
Public subnet
Private subnet
Internet Gateway
Route table
Route association
Security Group
Key pair
```

---

# 79. Deploy Dev

```powershell
cd environments\dev
```

Run:

```powershell
terraform init
terraform validate
terraform plan
terraform apply
```

Dev state manages the Dev EC2.

---

# 80. Deploy Staging

```powershell
cd ..\staging
```

Run:

```powershell
terraform init
terraform validate
terraform plan
terraform apply
```

---

# 81. Deploy Production

```powershell
cd ..\prod
```

Run:

```powershell
terraform init
terraform validate
terraform plan
terraform apply
```

---

# 82. Verify Infrastructure

Root:

```powershell
cd ..\..
terraform state list
terraform output
```

Dev:

```powershell
cd environments\dev
terraform state list
terraform output
```

Staging:

```powershell
cd ..\staging
terraform state list
terraform output
```

Production:

```powershell
cd ..\prod
terraform state list
terraform output
```

---

# 83. Verify Remote State

From the project root:

```powershell
aws s3 ls s3://YOUR-STATE-BUCKET --recursive
```

Expected:

```text
environments/dev/terraform.tfstate
environments/staging/terraform.tfstate
environments/prod/terraform.tfstate
root/terraform.tfstate
```

---

# 84. Troubleshooting

## Terraform command not found

Run:

```powershell
terraform version
```

If unavailable, ensure Terraform is installed and present in the system PATH.

---

## AWS authentication error

Run:

```powershell
aws sts get-caller-identity
```

If this fails, check AWS CLI configuration and credentials.

---

## Terraform says a resource already exists

Check Terraform state:

```powershell
terraform state list
```

If the resource exists in AWS but is not in Terraform state, determine whether it should be imported rather than recreated.

---

## Terraform wants to destroy an unexpected resource

Do not immediately apply.

Run:

```powershell
terraform plan
```

Look carefully for:

```text
- destroy
-/+ replace
```

If unexpected, stop and investigate.

---

## EC2 public IP changed

This can happen after stopping and starting an EC2 instance when an automatically assigned public IP is used.

Check:

```powershell
terraform output public_ip
```

---

## SSH connection fails

Check:

```text
EC2 is running
Security Group allows TCP 22
Correct public IP
Correct private key
Correct username
```

For Ubuntu:

```powershell
ssh -i "$env:USERPROFILE\.ssh\terraform-ec2" ubuntu@<PUBLIC_IP>
```

---

## GitHub Actions fails during validation

Check:

```text
.github/workflows/terraform.yml
```

Make sure the configuration does not reference a local Windows path such as:

```text
C:/Users/...
```

GitHub Actions runs on a separate runner and cannot access files from your computer.

---

# 85. Important Terraform Concepts Demonstrated

## Provider

Connects Terraform to AWS.

```hcl
provider "aws" {
  region = var.aws_region
}
```

## Resource

Creates or manages infrastructure.

```hcl
resource "aws_vpc" "main" {
}
```

## Data Source

Reads existing information.

```hcl
data "aws_ami" "ubuntu" {
}
```

## Variable

Accepts configuration input.

```hcl
variable "aws_region" {
}
```

## Local

Stores reusable local values.

```hcl
locals {
  project_name = "terraform-multienv"
}
```

## Output

Exposes useful values.

```hcl
output "vpc_id" {
}
```

## Module

Reusable Terraform configuration.

```hcl
module "ec2" {
}
```

## State

Terraform's record of managed infrastructure.

## Backend

Defines where Terraform state is stored.

## `count`

Creates indexed instances.

## `for_each`

Creates keyed instances.

## `depends_on`

Creates explicit dependencies.

## `lifecycle`

Controls resource lifecycle behavior.

---

# 86. Why We Used Modules

The EC2 configuration is shared across:

```text
Dev
Staging
Prod
```

Instead of duplicating the EC2 resource, one reusable module is used.

Benefits:

* Reusability
* Consistency
* Maintainability
* Standardization

---

# 87. Why We Used Separate States

Separate state provides environment isolation.

```text
Dev
 ↓
dev state

Staging
 ↓
staging state

Prod
 ↓
prod state
```

A change to Dev does not directly operate on resources managed by the Production state.

---

# 88. Why We Used S3 Backend

S3 provides centralized Terraform state.

Benefits:

* Shared state
* Persistence
* Versioning
* Encryption
* Locking
* Collaboration

Remote state is preferable to local state for team environments.

---

# 89. Why We Used Data Sources

The environments do not create duplicate shared infrastructure.

Instead they discover:

```text
Existing VPC
Existing subnet
Existing Security Group
Existing key pair
Ubuntu AMI
```

This allows multiple Terraform configurations to use existing infrastructure.

---

# 90. Why We Used Public and Private Subnets

The public subnet demonstrates internet-facing infrastructure.

The private subnet demonstrates network isolation.

The project does not deploy a workload into the private subnet because that would require additional networking such as NAT.

This keeps the project focused on Terraform fundamentals.

---

# 91. Why We Did Not Use NAT Gateway

A NAT Gateway would allow private subnet resources to initiate outbound internet connections.

It was intentionally excluded because:

* It adds AWS cost
* It isn't required for this learning project
* No private workload requires internet access

---

# 92. Why We Used IMDSv2

The EC2 module includes:

```hcl
metadata_options {
  http_endpoint = "enabled"
  http_tokens   = "required"
}
```

This requires IMDSv2 tokens and improves EC2 metadata access security.

The setting was added after reviewing Checkov security findings.

---

# 93. Final Verification Checklist

Before considering the project complete:

```text
[ ] Terraform installed
[ ] AWS CLI installed
[ ] AWS CLI configured
[ ] AWS authentication verified
[ ] Git installed
[ ] GitHub repository created
[ ] Terraform initialized
[ ] Terraform formatted
[ ] Terraform validated
[ ] VPC created
[ ] Public subnet created
[ ] Private subnet created
[ ] Internet Gateway created
[ ] Route table created
[ ] Route association created
[ ] Security Group created
[ ] SSH key configured
[ ] EC2 module created
[ ] Dev created
[ ] Staging created
[ ] Prod created
[ ] Separate states configured
[ ] S3 backend configured
[ ] S3 state locking configured
[ ] Checkov scan performed
[ ] IMDSv2 enabled
[ ] GitHub Actions configured
[ ] GitHub Actions CI passing
[ ] Final Terraform plans reviewed
[ ] Project pushed to GitHub
```

---

# 94. Final Architecture

```text
                    GitHub Repository
                           |
                           |
                    GitHub Actions
                           |
             ----------------------------
             |                          |
        Terraform CI              Terraform Code
             |                          |
             |                 ----------------------
             |                 |                    |
             |              Root State        Environment States
             |                 |                    |
             |                 |          ---------------------------
             |                 |          |            |            |
             |                 |         Dev        Staging       Prod
             |                 |          |            |            |
             |                 |          EC2          EC2          EC2
             |                 |
             |                 |
             |             Shared AWS Network
             |                 |
             |        ------------------------
             |        |          |            |
             |       VPC      Public       Private
             |                 Subnet       Subnet
             |                    |
             |               Route Table
             |                    |
             |               Internet Gateway
             |
             |
          Checkov
```

---

# 95. Complete Project Flow

```text
1. Install Terraform
        ↓
2. Install AWS CLI
        ↓
3. Configure AWS CLI
        ↓
4. Verify AWS authentication
        ↓
5. Install Git
        ↓
6. Create GitHub repository
        ↓
7. Initialize Git
        ↓
8. Configure AWS provider
        ↓
9. Create variables
        ↓
10. Create locals
        ↓
11. Create VPC
        ↓
12. Discover Availability Zones
        ↓
13. Create public subnet
        ↓
14. Create private subnet
        ↓
15. Create Internet Gateway
        ↓
16. Create route table
        ↓
17. Associate route table
        ↓
18. Create Security Group
        ↓
19. Create SSH key pair
        ↓
20. Create EC2 module
        ↓
21. Create Dev
        ↓
22. Create Staging
        ↓
23. Create Production
        ↓
24. Separate environment states
        ↓
25. Move state to S3
        ↓
26. Enable S3 state locking
        ↓
27. Demonstrate count
        ↓
28. Demonstrate for_each
        ↓
29. Learn depends_on
        ↓
30. Learn lifecycle
        ↓
31. Run Checkov
        ↓
32. Enable IMDSv2
        ↓
33. Add GitHub Actions CI
        ↓
34. Run final validation
        ↓
35. Run final plans
        ↓
36. Commit and push to GitHub
```

---

# 96. Interview Project Explanation

A concise explanation of the project:

> I built a Terraform-based AWS multi-environment infrastructure project to practice Infrastructure as Code and environment isolation.
>
> I started by provisioning a VPC with public and private subnets, an Internet Gateway, route table, route association, Security Group, and EC2 infrastructure.
>
> I then created a reusable EC2 Terraform module and used it across separate Dev, Staging, and Production environment configurations.
>
> Each environment has its own Terraform state, so changes in one environment do not directly operate on resources managed by another environment.
>
> For shared infrastructure, I used Terraform resources in the root configuration, while the environments use data sources to consume the existing VPC, subnet, Security Group, key pair, and AMI.
>
> I implemented Terraform variables, locals, outputs, data sources, modules, count, for_each, depends_on, lifecycle concepts, and state management.
>
> I initially used local state and then migrated the state to an encrypted Amazon S3 backend with versioning and S3-native state locking.
>
> I also used Checkov to scan the Terraform configuration for security issues and implemented IMDSv2 for the EC2 instances.
>
> Finally, I added GitHub Actions CI that automatically runs Terraform formatting and validation checks on pushes and pull requests.
>
> The project gave me practical experience with Terraform resource management, state, modules, multi-environment architecture, AWS networking, Security Groups, remote state, security scanning, and CI.

---

# 97. Key Lessons From the Project

## Terraform is declarative

You describe the desired infrastructure rather than writing procedural AWS instructions.

## State is critical

Terraform uses state to understand what infrastructure it manages.

## Modules provide reuse

A single EC2 module can be reused across multiple environments.

## Data sources read existing infrastructure

They do not create resources.

## Separate state provides environment isolation

Dev, Staging, and Production can be managed independently.

## Dependencies matter

Terraform automatically creates dependencies from resource references.

## `count` and `for_each` change resource addressing

This matters when modifying existing infrastructure.

## Remote state is important for teams

S3 provides centralized state and locking.

## `terraform plan` should be reviewed

Never blindly apply infrastructure changes.

## Security scanning identifies potential issues

Checkov helps identify areas requiring security review.

## CI catches configuration problems early

GitHub Actions can automatically validate Terraform before changes are merged.

---

# 98. Final Commands

Before pushing Terraform changes:

```powershell
terraform fmt -recursive
terraform validate
terraform plan
```

For Dev:

```powershell
cd environments\dev
terraform validate
terraform plan
```

For Staging:

```powershell
cd ..\staging
terraform validate
terraform plan
```

For Production:

```powershell
cd ..\prod
terraform validate
terraform plan
```

Return to the root:

```powershell
cd ..\..
```

Check Git:

```powershell
git status
```

Stage:

```powershell
git add .
```

Commit:

```powershell
git commit -m "Update Terraform infrastructure"
```

Push:

```powershell
git push origin main
```

---

# 99. Important Safety Notes

Never commit:

```text
terraform.tfstate
terraform.tfstate.*
.terraform/
private SSH keys
AWS access keys
AWS secret keys
```

Do not expose:

```text
C:\Users\<user>\.ssh\terraform-ec2
```

The `.pub` file contains public-key material, but the private key must remain private.

Before applying changes to Production:

```powershell
terraform plan
```

Always inspect the plan.

Pay particular attention to:

```text
destroy
replace
```

operations.

---

# 100. Project Outcome

This project demonstrates a practical Terraform workflow combining:

```text
Infrastructure as Code
        +
AWS
        +
Terraform Modules
        +
Multi-Environment Architecture
        +
Separate State
        +
S3 Remote State
        +
State Locking
        +
AWS Networking
        +
EC2
        +
Security Scanning
        +
GitHub Actions CI
```

The final result is a focused but complete Terraform project demonstrating the core skills required to work with Terraform and AWS infrastructure in a DevOps environment.

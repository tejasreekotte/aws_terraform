## AWS Terraform and CodeBuild POC

This Proof of Concept (POC) demonstrates how to provision infrastructure in AWS using **Terraform** with automation through **AWS CodeBuild**. The resources being provisioned include:

1. **S3 Bucket**
2. **EC2 Instance**

The workflow involves using AWS CodeBuild to execute the Terraform scripts, applying the configurations to provision resources in AWS.

## Repository Structure

```bash
aws_terraform/
├── bucket/
│   ├── main.tf                       # Terraform configuration for S3 bucket
│   └── variables.tf                  # Variables for S3 bucket configuration
├── vm/
│   ├── main.tf                       # Terraform configuration for EC2 instance
│   └── variables.tf                  # Variables for EC2 instance configuration
├── apply-terraform.sh                # Shell script to apply Terraform changes
├── buildspec.yml                     # AWS CodeBuild build specification
├── configure-named-profile.sh        # Script to configure AWS CLI profile
├── install-terraform.sh              # Script to install Terraform on CodeBuild
└── README.md                         # POC documentation (this file)
```

---

## Prerequisites

1. **AWS CLI**: Ensure that the AWS CLI is installed and configured on your system.
2. **Terraform**: Terraform should be installed on the system running the POC (or will be automatically installed during CodeBuild execution).
3. **AWS Account**: Ensure that you have appropriate IAM permissions to create S3 buckets, EC2 instances, and interact with CodeBuild.

---

## Step-by-Step Instructions

### 1. **AWS CLI Configuration**

Before running Terraform or the CodeBuild job, the AWS CLI must be configured with the necessary credentials. Use the `configure-named-profile.sh` script to set up the AWS CLI profile for CodeBuild.

#### Script: `configure-named-profile.sh`

```bash
#!/bin/bash

# Set up the named AWS CLI profile with access keys
aws configure set aws_access_key_id "<your_access_key>"
aws configure set aws_secret_access_key "<your_secret_key>"
aws configure set default.region "<your_aws_region>"
```

Replace `<your_access_key>`, `<your_secret_key>`, and `<your_aws_region>` with your actual AWS credentials. This ensures CodeBuild has access to your AWS resources.

---

### 2. **Installing Terraform**

If Terraform is not already installed, the `install-terraform.sh` script will handle it. This script is called by AWS CodeBuild to ensure that Terraform is available.

#### Script: `install-terraform.sh`

```bash
#!/bin/bash

# Check if terraform is installed, if not install it
if ! [ -x "$(command -v terraform)" ]; then
  echo "Installing Terraform..."
  wget https://releases.hashicorp.com/terraform/1.0.0/terraform_1.0.0_linux_amd64.zip
  unzip terraform_1.0.0_linux_amd64.zip
  sudo mv terraform /usr/local/bin/
else
  echo "Terraform is already installed."
fi
```

---

### 3. **S3 Bucket Provisioning**

In the `bucket/` directory, the Terraform configuration files for creating an S3 bucket are stored. The `main.tf` contains the core infrastructure logic, while `variables.tf` holds configurable values.

#### Terraform Configuration: `bucket/main.tf`

```hcl
provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "example_bucket" {
  bucket = var.bucket_name

  versioning {
    enabled = true
  }

  lifecycle_rule {
    id      = "log"
    enabled = true

    transition {
      days          = 30
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }
  }

  tags = {
    Name        = "TerraformBucket"
    Environment = "Dev"
  }
}
```

#### Variables: `bucket/variables.tf`

```hcl
variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
  default     = "example-terraform-bucket"
}

variable "region" {
  description = "AWS Region to deploy the bucket"
  default     = "us-east-1"
}
```

---

### 4. **EC2 Instance Provisioning**

In the `vm/` directory, the Terraform configuration files for provisioning an EC2 instance are stored.

#### Terraform Configuration: `vm/main.tf`

```hcl
provider "aws" {
  region = var.region
}

resource "aws_instance" "web_instance" {
  ami           = var.ami
  instance_type = var.instance_type

  tags = {
    Name = "TerraformEC2Instance"
  }
}
```

#### Variables: `vm/variables.tf`

```hcl
variable "ami" {
  description = "Amazon Machine Image ID for the EC2 instance"
  type        = string
  default     = "ami-0c55b159cbfafe1f0"  # Amazon Linux 2
}

variable "instance_type" {
  description = "The EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "region" {
  description = "AWS Region to deploy the instance"
  default     = "us-east-1"
}
```

---

### 5. **Applying Terraform Configuration**

Use the `apply-terraform.sh` script to initialize and apply the Terraform configurations for both the S3 bucket and EC2 instance.

#### Script: `apply-terraform.sh`

```bash
#!/bin/bash

# Initialize and apply the Terraform configurations
terraform init
terraform apply -auto-approve
```

This script is executed manually or as part of the CodeBuild pipeline to provision the defined AWS resources.

---

### 6. **AWS CodeBuild Setup**

The `buildspec.yml` file defines how AWS CodeBuild will execute the Terraform scripts to provision resources. It installs Terraform, configures the AWS CLI, and applies the Terraform configurations.

#### Build Specification: `buildspec.yml`

```yaml
version: 0.2

phases:
  install:
    commands:
      - ./install-terraform.sh  # Install Terraform if not present

  pre_build:
    commands:
      - ./configure-named-profile.sh  # Set up AWS CLI credentials

  build:
    commands:
      - cd bucket
      - terraform init  # Initialize Terraform in bucket directory
      - terraform apply -auto-approve  # Apply S3 bucket config
      - cd ../vm
      - terraform init  # Initialize Terraform in vm directory
      - terraform apply -auto-approve  # Apply EC2 instance config
```

This file ensures that AWS CodeBuild:

1. Installs Terraform.
2. Configures the AWS CLI profile.
3. Provisions the S3 bucket and EC2 instance by applying the Terraform configurations.

---

### 5. Build and Deploy via AWS CodeBuild

For continuous integration and deployment, AWS CodeBuild is configured to automatically run Terraform scripts whenever changes are pushed to the repository. The `buildspec.yml` file defines the build process.

## Setting Up AWS CodeBuild

To automate the Terraform deployment using AWS CodeBuild, follow these steps:

### Step 1: Create an IAM Role for CodeBuild

Ensure AWS CodeBuild has the necessary permissions to execute Terraform scripts and manage AWS resources.

1. **Navigate to IAM in the AWS Console**:
   - Go to the [IAM Console](https://console.aws.amazon.com/iam/).

2. **Create a New Role**:
   - Click on "Roles" in the sidebar.
   - Click "Create role".

3. **Select Trusted Entity**:
   - Choose "AWS service".
   - Select "CodeBuild".
   - Click "Next: Permissions".

4. **Attach Policies**:
   - **Managed Policies**:
     - `AmazonS3FullAccess` (if managing S3 buckets).
     - `AmazonEC2FullAccess` (if managing EC2 instances).
     - `AmazonVPCFullAccess` (if managing VPCs).
     - **Note**: It's recommended to create a custom policy with the least privileges required for your specific infrastructure.
   - **CodeBuild-Specific Policies**:
     - `AWSCodeBuildDeveloperAccess` or a custom policy granting necessary CodeBuild permissions.
     - `CloudWatchLogsFullAccess` for logging.
   
5. **Add Tags** (Optional):
   - Add any relevant tags for management or billing purposes.

6. **Review and Create**:
   - Name the role, e.g., `CodeBuildTerraformRole`.
   - Review the attached policies.
   - Click "Create role".

### Step 2: Set Up AWS CodeBuild Project

1. **Navigate to CodeBuild in the AWS Console**:
   - Go to the [CodeBuild Console](https://console.aws.amazon.com/codebuild/).

2. **Create a New Build Project**:
   - Click on "Create build project".

3. **Project Configuration**:

   - **Project Name**: Enter a descriptive name, e.g., `TerraformDeployment`.

   - **Description**: (Optional) Provide a brief description of the project.

4. **Source**:

   - **Source Provider**: Select "GitHub".

   - **Connect to GitHub**:
     - If not already connected, authorize AWS CodeBuild to access your GitHub account.
     - Select the repository `aws_terraform`.
   
   - **Branch**: Specify the branch to build from, e.g., `main` or `master`.

   - **Webhook**: (Optional) Enable webhook to trigger builds on code changes.

5. **Environment**:

   - **Environment Image**: Choose "Managed image".

   - **Operating System**: Select "Ubuntu".

   - **Runtime(s)**: Standard.

   - **Image**: Select the latest available, e.g., `aws/codebuild/standard:5.0`.

   - **Service Role**: Select the IAM role created earlier (`CodeBuildTerraformRole`).

   - **Environment Variables**: (Optional) Define any environment variables required by your scripts or Terraform configurations.

6. **Buildspec**:

   - **Build Specification**: Select "Use the buildspec file in the source code".

   - Ensure that the `buildspec.yml` file is present in the root of the repository.

7. **Artifacts**:

   - **Artifacts Type**: Select "No artifacts" as Terraform typically doesn't produce build artifacts.

8. **Logs**:

   - Enable CloudWatch Logs for monitoring build logs.

9. **Tags**: (Optional) Add tags for organization or billing purposes.

10. **Create Project**:
    - Review all configurations.
    - Click "Create build project".

### Step 3: Configure `buildspec.yml`

Ensure that the `buildspec.yml` file in your repository is correctly set up to execute Terraform commands. Below is an example configuration:

```yaml
version: 0.2

phases:
  install:
    runtime-versions:
      terraform: 1.4
    commands:
      - echo Installing necessary tools...
      - chmod +x install-terraform.sh
      - ./install-terraform.sh
  pre_build:
    commands:
      - echo Configuring AWS credentials...
      - chmod +x configure-named-profile.sh
      - ./configure-named-profile.sh
      - echo Initializing Terraform...
      - terraform init
  build:
    commands:
      - echo Planning Terraform deployment...
      - terraform plan -out=tfplan
      - echo Applying Terraform deployment...
      - terraform apply -auto-approve tfplan
  post_build:
    commands:
      - echo Terraform deployment completed successfully.
artifacts:
  files:
    - '**/*'
  discard-paths: yes
```

#### Explanation of `buildspec.yml` Phases:

- **install**:
  - Specifies the Terraform version.
  - Executes the Terraform installation script to ensure Terraform is available in the build environment.

- **pre_build**:
  - Runs the AWS CLI configuration script to set up named profiles.
  - Initializes Terraform, downloading necessary providers and setting up the working directory.

- **build**:
  - Executes `terraform plan` to create an execution plan and saves it to `tfplan`.
  - Applies the Terraform plan automatically without manual approval using `terraform apply -auto-approve tfplan`.

- **post_build**:
  - Outputs a completion message indicating successful deployment.

- **artifacts**:
  - Specifies that no artifacts are required (`discard-paths: yes` ensures no artifacts are stored).

### Step 4: Trigger a Build

Once the CodeBuild project is set up, you can trigger builds in the following ways:

1. **Manual Trigger**:
   - Navigate to your CodeBuild project in the AWS Console.
   - Click "Start build" to initiate a build manually.

2. **Automatic Trigger via Webhook**:
   - If you enabled webhooks during project setup, any push to the specified branch (e.g., `main`) will automatically trigger a build.

### Step 5: Monitor the Build Process

Monitor the build process through the AWS CodeBuild Console:

1. **Build Status**:
   - View the status of ongoing and completed builds.

2. **Build Logs**:
   - Access detailed logs for each build phase in CloudWatch Logs or directly within the CodeBuild Console.

3. **Troubleshooting**:
   - Review logs to identify and resolve any issues encountered during the build and deployment process.


### Conclusion

This POC demonstrates the following key steps:

- **AWS CLI Configuration**: Ensures CodeBuild has access to your AWS resources.
- **Terraform S3 Bucket and EC2 Instance Creation**: Terraform scripts are used to provision these resources.
- **CodeBuild Automation**: AWS CodeBuild automates the execution of the Terraform scripts, allowing for infrastructure provisioning to be done without manual intervention.

This workflow can be expanded to include other AWS services, more complex configurations, and CI/CD integrations for automated deployments.

---
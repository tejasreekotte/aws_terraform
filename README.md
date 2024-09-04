# AWS Terraform Repository

## Overview

This repository contains Terraform configurations and associated scripts designed to automate the deployment and management of infrastructure on Amazon Web Services (AWS). It leverages AWS CodeBuild for continuous integration and deployment (CI/CD), enabling automated provisioning, updating, and teardown of AWS resources through Terraform scripts.

## Prerequisites

Before using the Terraform configurations and setting up AWS CodeBuild, ensure you have the following:

- **AWS Account**: Necessary to deploy and manage AWS resources.
- **AWS CLI**: Installed and configured with your AWS credentials. [Installation Guide](https://aws.amazon.com/cli/)
- **Terraform**: Installed on your local machine or CI/CD environment. [Download Terraform](https://www.terraform.io/downloads)
- **Git**: Installed for cloning the repository.
- **IAM Permissions**: Appropriate permissions to create and manage AWS resources and CodeBuild projects.
- **GitHub Account**: To access and clone the repository.

## Repository Structure

```
aws_terraform/
├── apply-terraform.sh
├── buildspec.yml
├── configure-named-profile.sh
├── install-terraform.sh
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
└── README.md
```

### File Descriptions

- **`main.tf`**: The primary Terraform configuration file defining AWS resources such as EC2 instances, S3 buckets, VPCs, etc.
  
- **`variables.tf`**: Contains variable declarations used in the Terraform configurations, allowing for flexible and reusable setups.

- **`outputs.tf`**: Defines output values from the Terraform configurations, such as resource IDs, IP addresses, and URLs.

- **`terraform.tfvars`**: Stores the values for variables declared in `variables.tf`, enabling customization for different environments or use cases.

- **`apply-terraform.sh`**: Shell script to automate Terraform commands, including initialization, planning, and applying configurations.

- **`buildspec.yml`**: AWS CodeBuild configuration file that outlines the build phases and commands to execute during the CI/CD process.

- **`configure-named-profile.sh`**: Shell script to set up AWS CLI named profiles, facilitating the use of specific credentials for Terraform operations.

- **`install-terraform.sh`**: Shell script to install Terraform in the build environment or local machine.

- **`README.md`**: This documentation file providing an overview and usage instructions for the repository.

## Usage

### 1. Clone the Repository

Clone this repository to your local machine using Git:

```bash
git clone https://github.com/tejasreekotte/aws_terraform.git
cd aws_terraform
```

### 2. Configure AWS Profile

Run the script to set up your AWS CLI with a named profile:

```bash
./configure-named-profile.sh
```

This script will prompt you to enter your AWS Access Key ID, Secret Access Key, and default region. It sets up a named profile in your AWS CLI configuration, which Terraform will use for authentication.

### 3. Install Terraform

Execute the installation script to install Terraform:

```bash
./install-terraform.sh
```

This script downloads and installs the specified version of Terraform, ensuring that the correct version is used for your configurations.

### 4. Apply Terraform Configuration

Use the provided script to initialize, plan, and apply the Terraform configurations:

```bash
./apply-terraform.sh
```

This script performs the following steps:

1. **Initialize Terraform**: Downloads necessary provider plugins and sets up the working directory.
2. **Plan Infrastructure**: Creates an execution plan, allowing you to review changes before applying them.
3. **Apply Configuration**: Deploys the defined infrastructure to AWS.

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
     - Select the repository `tejasreekotte/aws_terraform`.
   
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


## Conclusion

This repository streamlines the deployment and management of AWS infrastructure using Terraform, integrated seamlessly with AWS CodeBuild for automated CI/CD workflows. By following the provided setup instructions and adhering to best practices, you can achieve efficient, secure, and scalable infrastructure automation.

Feel free to customize and extend the configurations to suit your specific project requirements. If you encounter any issues or have suggestions for improvements, please open an issue or submit a pull request.

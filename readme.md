# Deployment and Testing Documentation

## **1. Building and Pushing the Docker Image to ECR**

### **Prerequisites**

Ensure the following are installed and configured on your local system:

- Docker
- AWS CLI (configured with appropriate credentials)

## Building and Testing the Docker Image Locally

### Using Makefile

**Available Commands**

- Build the Docker image:

```bash
   make build
```

- Run the Docker container locally:

```bash
   make run
```

- Test the Lambda function locally:

```bash
   make test
```

- Stop the running Docker container:

```bash
   make stop
```

- Remove the stopped Docker container:

```bash
   make remove
```

- Stop and remove the Docker container:

```bash
   make clean
```

**Note: You can also use below steps without make command as well**

### **Steps**

1. **Build the Docker Image**:

   After cloning the repo navigate to the directory containing your `Dockerfile` and run the following command to build the Docker image:

   ```bash
   docker build -t demo-lambda-function .
   ```

2. **Run the Docker Container Locally:**:

   After the image is built, you can run it locally. The -p 9000:8080 option maps port 8080 inside the container to port 9000 on your host system.

```bash
      docker run -p 9000:8080 demo-lambda-function
```

The Docker container will start, and your Lambda function will be accessible locally.

2. **Test the Lambda Function Locally:**

   Use curl to invoke the Lambda function locally by sending a POST request to the local server on port 9000. This simulates the request that AWS Lambda would handle.

```bash
curl -X POST \
 http://localhost:9000/2015-03-31/functions/function/invocations \
 -H "Content-Type: application/json" \
 -d '{"path": "/list-games", "httpMethod": "GET"}'
```

3. **Example Response**

```bash
{
  "statusCode": 200,
  "body": "{\"games\": [\"Chess\", \"Football\"]}"
}
```

## **2. Deploying the Infrastructure Using Terraform**

### **Prerequisites**

Ensure the following are installed and configured on your local system:

- Terraform
- AWS CLI (configured with appropriate credentials)

### **Steps**

1. **Initialize the Terraform Working Directory**:
   Navigate to the `terraform` directory which contains Terraform config files and run:

   ```bash
   terraform init
   ```

2. **Review the Terraform Plan**:
   Preview the changes that will be made to your infrastructure:

   ```bash
   terraform plan
   ```

   **Note:** All the variables have default values. So, if you want to override the variables then you can create `variable.tfvars` and define the variables values and run below code.

   ```bash
     terraform plan -var-file=variables.tfvars
   ```

3. **Apply the Terraform Configuration**:
   Deploy the infrastructure:

   ```bash
   terraform apply
   ```

   Confirm the prompt to proceed with the deployment.

4. **Verify the Deployment**:
   - Check the created resources in the AWS Management Console.
   - Ensure the Lambda function, API Gateway, and associated resources are configured as expected.

---

## **3. Testing the API Endpoints Using the Generated API Key**

### **Retrieving the API Key**

1. **List All API Keys**:

   ```bash
   aws apigateway get-api-keys --query 'items[].[id, name]' --output table
   ```

   **Note:** The ID of the desired API key which will be `DemoAPIKey`.

2. **Retrieve the API Key Value**:
   ```bash
   aws apigateway get-api-key --api-key <API_KEY_ID> --include-value
   ```
   Replace `<API_KEY_ID>` with the actual key ID from the previous step. The `value` field in the response is your API key.

### **Using the API Key**

#### **With `curl`**:

```bash
    curl -X GET https://$(terraform output -raw api_url)/list-games \
    -H "x-api-key: <API_KEY_VALUE>"
```

Replace `<API_KEY_VALUE>` with the retrieved API key.

#### **With Postman**:

1. Open Postman and create a new request.
2. Enter the API Gateway URL as the request URL.
3. Go to the **Headers** tab and add:
   - **Key**: `x-api-key`
   - **Value**: `<API_KEY_VALUE>`
4. Send the request and verify the response.

---

By following these instructions, you can successfully build, deploy, and test the Python application in AWS using Docker, Terraform, and API Gateway.

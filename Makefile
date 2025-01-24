# Define variables
IMAGE_NAME = demo-lambda-function
CONTAINER_NAME = $(IMAGE_NAME)-container

.PHONY: build run test stop remove clean

# Build the Docker image
build:
	docker build -t $(IMAGE_NAME) .

# Run the Docker container locally
run:
	docker run -p 9000:8080 --name $(CONTAINER_NAME) -d $(IMAGE_NAME)

# Stop the running container
stop:
	docker stop $(CONTAINER_NAME) || true

# Remove the stopped container
remove:
	docker rm $(CONTAINER_NAME) || true

# Stop and remove the container
clean: stop remove

# Test the Lambda function locally
test:
	curl -X POST \
	http://localhost:9000/2015-03-31/functions/function/invocations \
	-H "Content-Type: application/json" \
	-d '{"path": "/list-games", "httpMethod": "GET"}'


FROM public.ecr.aws/lambda/python:3.12

# Copy requirements.txt from the src folder
COPY src/requirements.txt ${LAMBDA_TASK_ROOT}

# Install the specified packages
RUN pip install --no-cache-dir -r requirements.txt

# Copy function code
COPY src/lambda_function.py ${LAMBDA_TASK_ROOT}

# Command to run the Lambda function
CMD ["lambda_function.lambda_handler"]
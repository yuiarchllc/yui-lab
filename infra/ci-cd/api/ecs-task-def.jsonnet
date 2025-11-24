{
  "family": "yui-lab-task",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "256",
  "memory": "512",
  "executionRoleArn": "{{ tfstate `aws_iam_role.ecs_task_execution_role.arn` }}",
  "taskRoleArn": "{{ tfstate `aws_iam_role.ecs_task_role.arn` }}",
  "containerDefinitions": [
    {
      "name": "yui-lab-api",
      "image": "467737513669.dkr.ecr.ap-northeast-1.amazonaws.com/yui-lab-api:latest",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 80,
          "hostPort": 80
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "{{ tfstate `aws_cloudwatch_log_group.ecs.name` }}",
          "awslogs-region": "ap-northeast-1",
          "awslogs-stream-prefix": "yui-lab-app"
        }
      },
      "environment": []
    }
  ]
}
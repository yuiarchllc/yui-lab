{
  "serviceName": "{{ tfstate `aws_ecs_service.php_app.name` }}",
  "taskDefinition": "{{ tfstate `aws_ecs_task_definition.php_app.family` }}",
  "desiredCount": 1,
  "launchType": "FARGATE",
  "networkConfiguration": {
    "awsvpcConfiguration": {
      "subnets": [
        "{{ tfstate `aws_subnet.public1.id` }}",
        "{{ tfstate `aws_subnet.public2.id` }}"
      ],
      "securityGroups": [
        "{{ tfstate `aws_security_group.ecs.id` }}"
      ],
      "assignPublicIp": "ENABLED"
    }
  },
  "loadBalancers": [
    {
      "targetGroupArn": "{{ tfstate `aws_lb_target_group.api.arn` }}",
      "containerName": "yui-lab-api",
      "containerPort": 80
    }
  ]
}
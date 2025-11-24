resource "aws_key_pair" "this" {
  key_name   = "${local.general.service_name}-aws_key_pair"
  public_key = file("../keys/id_rsa.pub")
}

resource "aws_instance" "this" {
  ami           = local.ec2.ami
  instance_type = local.ec2.instance_type
  subnet_id     = aws_subnet.public1.id
  vpc_security_group_ids = [
    aws_security_group.ec2.id,
  ]
  iam_instance_profile        = aws_iam_instance_profile.this.name
  associate_public_ip_address = true
  key_name                    = aws_key_pair.this.id
  root_block_device {
    volume_size = local.ec2.root_volume_size
    volume_type = local.ec2.root_volume_type
  }
  user_data = <<-EOF
#!/bin/bash
yum update -y
yum install php8.2 httpd -y

dnf install mariadb105 -y

systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

systemctl enable httpd
systemctl start httpd

mkdir -p /var/www/html/app
echo "<html><body><h1>Hello</h1></body></html>" > /var/www/html/app/index.html
  EOF
}

resource "aws_iam_instance_profile" "this" {
  name = aws_iam_role.this.name
  role = aws_iam_role.this.name
}
provider "aws" {
  region = "ap-south-1"   # Change to your preferred region
}

# Key pair for SSH access
resource "aws_key_pair" "shopping_key" {
  key_name   = "shopping-key"
  public_key = file("~/.ssh/id_rsa.pub")   # Use your public key
}

# Security group to allow HTTP and SSH
resource "aws_security_group" "shopping_sg" {
  name        = "shopping-sg"
  description = "Allow HTTP and SSH"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 instance
resource "aws_instance" "shopping_ec2" {
  ami           = "ami-09ed39e30153c3bf9" # Amazon Linux 2 AMI (update for your region)
  instance_type = "t2.micro"
  key_name      = aws_key_pair.shopping_key.key_name
  security_groups = [aws_security_group.shopping_sg.name]

  #user_data = <<-EOF
  #            #!/bin/bash
  #            sudo yum update -y
  #            sudo yum install -y httpd
  #            sudo systemctl start httpd
  #            sudo systemctl enable httpd

  #            echo "<h1>Welcome to Balaji's Shopping Site</h1>" | sudo tee /var/www/html/index.html
  #            echo "<p>Products: Shoes, Bags, Watches</p>" | sudo tee -a /var/www/html/index.html
  #            EOF

user_data = <<-EOF
            #!/bin/bash
            sudo yum update -y
            sudo yum install -y httpd awscli
            sudo systemctl start httpd
            sudo systemctl enable httpd
            # Sync website content from S3
            aws s3 sync s3://console-admin-test-bucket /var/www/html --region ap-south-1
            echo "*/1 * * * * root aws s3 sync s3://console-admin-test-bucket /var/www/html --delete --region ap-south-1" >> /etc/crontab
            EOF

  tags = {
    Name = "shopping-website"
  }
}

output "website_url" {
  value = aws_instance.shopping_ec2.public_dns
}

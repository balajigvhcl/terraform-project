resource "aws_instance" "techlabs-local" {
  ami        = "ami-09ed39e30153c3bf9"  # Replace this with the latest Amazon Linux AMI in your region
  instance_type = "t2.micro"

user_data = <<-EOF
            #!/bin/bash
            yum install -y httpd
            systemctl start httpd
            systemctl enable httpd
            echo "<h1> hello from techlab-webserver-01 !!</h1>"  > /var/www/html/index.html
            EOF
  tags = {
 Name = "techlab-webserver-01"
  }
}

# ==============================================================================
# DATA
# ==============================================================================

data "aws_subnet" "web" {
  id = var.subnet_id
}

data "aws_ami" "latest_amazonlinux" {
  owners      = ["137112412989"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# ==============================================================================
# RESOURCES
# ==============================================================================

resource "aws_instance" "server" {
  ami                    = data.aws_ami.latest_amazonlinux.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.server.id]
  user_data              = <<EOF
#! /bin/bash
yum -y update
yum -y install httpd

MYIP=`curl http://169.254.169.254/latest/meta-data/local-ipv4`

cat <<HTMLTEXT > /var/www/html/index.html
<h2>
${var.message} webserver with IP: $myip
${var.message} webserver in AZ: ${data.aws_subnet.web.id}<br>
message:</h2> ${var.message}

HTMLTEXT
service httpd start
chkconfig httpd on
EOF

  tags = {
    name  = "${var.name}-webserver-${var.subnet_id}"
    owner = "Guillaume Penaud"
  }
}

resource "aws_security_group" "server" {
  name_prefix = "${var.name}-webserver-sg"
  description = "${var.name} security group for my webserver on subnet ${var.subnet_id}"

  ingress {
    description = "allow http port (80) on ingress"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "allow all ports on egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    name  = "webserver-sg"
    owner = "Guillaume Penaud"
  }
}

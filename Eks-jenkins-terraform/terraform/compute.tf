
data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = [
      "amzn2-ami-hvm-*-x86_64-gp2",
    ]
  }
  filter {
    name = "owner-alias"
    values = [
      "amazon",
    ]
  }
}

resource "aws_instance" "jenkins-instance" {
#  ami             = "${data.aws_ami.amazon-linux-2.id}"
  ami              = "amzn2-ami-hvm-2.0.20180622.1-x86_64-gp2"
  instance_type   = "t2.medium"
#  key_name        = "${var.keyname}"
  key_name        = "aws_key_pair.deployer.key_name"
  #vpc_id          = "${aws_vpc.development-vpc.id}"
  vpc_security_group_ids = ["${aws_security_group.sg_allow_ssh_jenkins.id}"]
#  subnet_id          = "${aws_subnet.public-subnet-1.id}"
  subnet_id          = "aws_subnet.public-subnet-1.id"
  #name            = "${var.name}"
#  user_data = ${file("install_jenkins.sh")}
  user_data = "data.template_file.user_data.rendered"

  associate_public_ip_address = true
  tags = {
    Name = "Jenkins-Instance"
  }
}

resource "aws_security_group" "sg_allow_ssh_jenkins" {
  name        = "allow_ssh_jenkins"
  description = "Allow SSH and Jenkins inbound traffic"
  vpc_id      = "aws_vpc.development-vpc.id"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

output "jenkins_ip_address" {
  value = "${aws_instance.jenkins-instance.public_dns}"
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDF+n4+xsJLvFIRPi1EChe2JwoqNJM+qCjm8n2a8fxaIFWsRJSfpkN8DGDS9Mv+WCelcJ1tu8caClMj3q52emHDjsFjboSIiaS1PVJG3sTytCZhOPvtdSoN31ASlcR5ncdjGlF+1wvJWBO+9S6Yf71X0FKZxnHbB6hr0sfShckcGFcxEM42okhNmYa4XOfk8woJvSrpHjKPVfMVexWsMwdImLWCiNsUuYJsEfbotnWdXrBLs64GdFLk2mYTAF2XhabYiwWw5iJrb6KNWVf4hg2cLjAnTi8B0o/nkEhf2lIuN4XfEH59ZH8HylbZmo2GuWU4PpLcIxeszdv+f/DLJYUb Bala@Admins-MacBook-Pro.local"
}

data "template_file" "user_data" {
  template = "${file("install_jenkins.sh.tpl")}"
# {
#   template = <<EOF
#install_jenkins.sh
#EOF
#}
}

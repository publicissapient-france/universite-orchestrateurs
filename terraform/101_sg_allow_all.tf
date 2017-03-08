resource "aws_security_group" "allow_all" {

  vpc_id = "${aws_vpc.main.id}"
  name_prefix = "mesos-starter-sg"
  description = "Allow all inbound traffic"

  ingress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  tags{
    Owner = "${var.owner}"
  }
}
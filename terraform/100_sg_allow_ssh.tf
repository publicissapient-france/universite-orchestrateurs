resource "aws_security_group" "allow_ssh" {
  vpc_id = "${aws_vpc.main.id}"
  name_prefix = "mesos-starter-sg"
  description = "Allow ssh inbound traffic"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  ingress {
    protocol = "icmp"
    from_port = 30
    # traceroute
    to_port = 0
  }

  tags {
    Name = "${var.project_name} - public sg"
  }
}
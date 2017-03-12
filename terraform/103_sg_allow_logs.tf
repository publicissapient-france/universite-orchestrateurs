resource "aws_security_group" "allow_logs" {
  vpc_id      = "${aws_vpc.main.id}"
  name_prefix = "mesos-starter-sg"
  description = "Allow graylog to receive logs"

  ingress {
    from_port   = 12000
    to_port     = 13000
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.project_name} - allow logs"
  }
}

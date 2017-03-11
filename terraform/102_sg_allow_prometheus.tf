resource "aws_security_group" "allow_prometheus" {
  vpc_id      = "${aws_vpc.main.id}"
  name_prefix = "mesos-starter-sg"
  description = "Allow prometheus inbound traffic"

  ingress {
    from_port   = 9100
    to_port     = 9110
    protocol    = "tcp"
    cidr_blocks = ["${aws_subnet.monitoring.cidr_block}"]
  }

  tags {
    Name = "${var.project_name} - allow prometheus"
  }
}

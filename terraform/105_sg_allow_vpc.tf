resource "aws_security_group" "allow_vpc" {
  vpc_id      = "${aws_vpc.main.id}"
  name_prefix = "mesos-starter-sg"
  description = "internal vpc security group"

  tags {
    Name = "${var.project_name} - sg vpc"
  }

  ingress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "${aws_vpc.main.cidr_block}",
    ]
  }
}

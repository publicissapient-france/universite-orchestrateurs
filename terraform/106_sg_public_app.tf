resource "aws_security_group" "allow_public_app" {
  vpc_id      = "${aws_vpc.main.id}"
  name_prefix = "mesos-starter-sg"
  description = "publicly exposed ports"

  tags {
    Name = "${var.project_name} - sg vpc"
  }

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  ingress {
    from_port = 6443
    to_port   = 6443
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  ingress {
    from_port = 5050
    to_port   = 5050
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  ingress {
    from_port = 8000
    to_port   = 10000
    protocol  = "tcp"


    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }


}

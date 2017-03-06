


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

resource "aws_instance" "bastion" {
  ami = "${data.aws_ami.ubuntu.id}"
  key_name = "${aws_key_pair.access.key_name}"
  instance_type = "t2.micro"

  associate_public_ip_address = true
  source_dest_check = false

  tags = {
    Name = "${var.project_name} - bastion"
    Owner = "${var.owner}"
  }

  subnet_id = "${aws_subnet.public.id}"
  vpc_security_group_ids = ["${aws_security_group.allow_ssh.id}"]
}
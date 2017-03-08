

resource "aws_instance" "swarm_master" {
  count = "${var.swarm_master_count}"
  ami = "${data.aws_ami.ubuntu.id}"
  key_name = "${aws_key_pair.access.key_name}"
  instance_type = "t2.medium"
  user_data = "${file("cloudinit.sh")}"

  associate_public_ip_address = true
  subnet_id = "${aws_subnet.swarm_master.id}"
  vpc_security_group_ids = ["${aws_security_group.allow_all.id}"]

  tags {
    Name = "${var.project_name} - swarm master ${count.index + 1}"
    Group = "${var.project_name}"
    Owner = "${var.owner}"
  }

}

resource "aws_instance" "swarm_worker" {
  count = "${var.swarm_worker_count}"
  ami = "${data.aws_ami.ubuntu.id}"
  key_name = "${aws_key_pair.access.key_name}"
  instance_type = "t2.medium"

  user_data = "${file("cloudinit.sh")}"

  associate_public_ip_address = true
  subnet_id = "${aws_subnet.swarm_worker.id}"
  vpc_security_group_ids = ["${aws_security_group.allow_all.id}"]

  tags {
    Name = "${var.project_name} - swarm worker ${count.index + 1}"
    Group = "${var.project_name}"
    Owner = "${var.owner}"
  }
}

#
# NETWORK
#

/* master subnet */
resource "aws_subnet" "swarm_master" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${cidrsubnet(aws_vpc.main.cidr_block, 8, 4)}"
  tags {
    Name = "${var.project_name} - swarm master"
    Group = "${var.project_name}"
    Owner = "${var.owner}"
  }
}

resource "aws_route_table_association" "swarm_master" {
  subnet_id = "${aws_subnet.swarm_master.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_subnet" "swarm_worker" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${cidrsubnet(aws_vpc.main.cidr_block, 8, 5)}"
  tags {
    Name = "${var.project_name} - swarm worker"
    Group = "${var.project_name}"
    Owner = "${var.owner}"
  }
}

resource "aws_route_table_association" "swarm_worker" {
  subnet_id = "${aws_subnet.swarm_worker.id}"
  route_table_id = "${aws_route_table.public.id}"
}
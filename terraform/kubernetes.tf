

resource "aws_instance" "kubernetes_master" {
  count = "${var.kubernetes_master_count}"
  ami = "${data.aws_ami.ubuntu.id}"
  key_name = "${aws_key_pair.access.key_name}"
  instance_type = "t2.medium"

  user_data = "${file("cloudinit.sh")}"

  associate_public_ip_address = true
  subnet_id = "${aws_subnet.kubernetes_master.id}"
  vpc_security_group_ids = ["${aws_security_group.allow_ssh.id}"]

  tags {
    Name = "${var.project_name} - kubernetes master ${count.index + 1}"
    Group = "${var.project_name}"
    Owner = "${var.owner}"
  }
}

resource "aws_instance" "kubernetes_worker" {
  count = "${var.kubernetes_worker_count}"
  ami = "${data.aws_ami.ubuntu.id}"
  key_name = "${aws_key_pair.access.key_name}"
  instance_type = "t2.medium"
  user_data = "${file("cloudinit.sh")}"

  associate_public_ip_address = true
  subnet_id = "${aws_subnet.kubernetes_worker.id}"
  vpc_security_group_ids = ["${aws_security_group.allow_ssh.id}"]

  tags {
    Name = "${var.project_name} - kubernetes worker ${count.index + 1}"
    Group = "${var.project_name}"
    Owner = "${var.owner}"
  }
}

#
# NETWORK
#

/* master subnet */
resource "aws_subnet" "kubernetes_master" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${cidrsubnet(aws_vpc.main.cidr_block, 8, 6)}"
  tags {
    Name = "${var.project_name} - kubernetes master"
    Group = "${var.project_name}"
    Owner = "${var.owner}"
  }
}

resource "aws_route_table_association" "kubernetes_master" {
  subnet_id = "${aws_subnet.kubernetes_master.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_subnet" "kubernetes_worker" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${cidrsubnet(aws_vpc.main.cidr_block, 8, 7)}"
  tags {
    Name = "${var.project_name} - kubernetes worker"
    Group = "${var.project_name}"
    Owner = "${var.owner}"
  }
}

resource "aws_route_table_association" "kubernetes_worker" {
  subnet_id = "${aws_subnet.kubernetes_worker.id}"
  route_table_id = "${aws_route_table.public.id}"
}
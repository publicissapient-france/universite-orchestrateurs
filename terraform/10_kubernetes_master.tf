resource "aws_instance" "kubernetes-master" {
  count = "${var.kubernetes-master_count}"
  ami = "${data.aws_ami.ubuntu.id}"
  key_name = "${aws_key_pair.access.key_name}"
  instance_type = "t2.medium"

  user_data = "${file("cloudinit.sh")}"

  associate_public_ip_address = true
  subnet_id = "${aws_subnet.kubernetes-master.id}"
  vpc_security_group_ids = [
    "${aws_security_group.allow_all.id}",
    "${aws_security_group.allow_prometheus.id}"
  ]

  tags {
    Name = "${var.project_name} - kubernetes master ${count.index + 1}"
    Group = "${var.project_name}"
    Owner = "${var.owner}"
  }
}

resource "aws_subnet" "kubernetes-master" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${cidrsubnet(aws_vpc.main.cidr_block, 8, 6)}"
  tags {
    Name = "${var.project_name} - kubernetes master"
    Group = "${var.project_name}"
    Owner = "${var.owner}"
  }
}

resource "aws_route_table_association" "kubernetes-master" {
  subnet_id = "${aws_subnet.kubernetes-master.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route53_record" "kubernetes-master" {
  count = "${var.kubernetes-master_count}"
  zone_id = "${aws_route53_zone.private.zone_id}"
  name = "kubernetes-master${count.index + 1}.private"
  type = "A"
  ttl = "300"
  records = [
    "${element(aws_instance.kubernetes-master.*.private_ip, count.index)}"]
}
resource "aws_instance" "mesos-worker" {
  count         = "${var.mesos-worker_count}"
  ami           = "${data.aws_ami.ubuntu.id}"
  key_name      = "${aws_key_pair.access.key_name}"
  instance_type = "t2.medium"

  user_data = "${file("cloudinit.sh")}"

  associate_public_ip_address = true
  subnet_id                   = "${aws_subnet.mesos-worker.id}"

  iam_instance_profile = "${aws_iam_instance_profile.rexray-worker.id}"

  vpc_security_group_ids = [
    "${aws_security_group.allow_ssh.id}",
    "${aws_security_group.allow_vpc.id}",
    "${aws_security_group.allow_prometheus.id}",
  ]

  tags {
    Name  = "${var.project_name} - mesos worker ${count.index + 1}"
    Group = "${var.project_name}"
    Owner = "${var.owner}"
  }
}

resource "aws_subnet" "mesos-worker" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "${cidrsubnet(aws_vpc.main.cidr_block, 8, 3)}"

  tags {
    Name  = "${var.project_name} - mesos worker"
    Group = "${var.project_name}"
    Owner = "${var.owner}"
  }
}

resource "aws_route_table_association" "mesos-worker" {
  subnet_id      = "${aws_subnet.mesos-worker.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route53_record" "mesos-worker" {
  count   = "${var.mesos-worker_count}"
  zone_id = "${aws_route53_zone.private.zone_id}"
  name    = "mesos-worker${count.index + 1}.private"
  type    = "A"
  ttl     = "300"

  records = [
    "${element(aws_instance.mesos-worker.*.private_ip, count.index)}",
  ]
}

resource "aws_route53_record" "mesos-worker-public" {
  count   = "${var.mesos-worker_count}"
  zone_id = "${data.aws_route53_zone.xebia_public_dns.id}"
  name    = "mesos-worker${count.index + 1}.${var.public_subdomain}"
  type    = "A"
  ttl     = "300"

  records = [
    "${element(aws_instance.mesos-worker.*.public_ip, count.index)}",
  ]
}

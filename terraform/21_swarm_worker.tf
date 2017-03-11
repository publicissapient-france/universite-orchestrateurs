#
# WORKER
#
########################################################################################################################

resource "aws_instance" "swarm-worker" {
  count         = "${var.swarm-worker_count}"
  ami           = "${data.aws_ami.ubuntu.id}"
  key_name      = "${aws_key_pair.access.key_name}"
  instance_type = "t2.medium"

  user_data = "${file("cloudinit.sh")}"

  associate_public_ip_address = true
  subnet_id                   = "${aws_subnet.swarm-worker.id}"

  vpc_security_group_ids = [
    "${aws_security_group.allow_all.id}",
    "${aws_security_group.allow_prometheus.id}",
  ]

  tags {
    Name  = "${var.project_name} - swarm worker ${count.index + 1}"
    Group = "${var.project_name}"
    Owner = "${var.owner}"
  }
}

resource "aws_subnet" "swarm-worker" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "${cidrsubnet(aws_vpc.main.cidr_block, 8, 5)}"

  tags {
    Name  = "${var.project_name} - swarm worker"
    Group = "${var.project_name}"
    Owner = "${var.owner}"
  }
}

resource "aws_route_table_association" "swarm-worker" {
  subnet_id      = "${aws_subnet.swarm-worker.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route53_record" "swarm-worker" {
  count   = "${var.swarm-worker_count}"
  zone_id = "${aws_route53_zone.private.zone_id}"
  name    = "swarm-worker${count.index + 1}.private"
  type    = "A"
  ttl     = "300"

  records = [
    "${element(aws_instance.swarm-worker.*.private_ip, count.index)}",
  ]
}

resource "aws_route53_record" "swarm-worker-public" {
  count   = "${var.swarm-worker_count}"
  zone_id = "${data.aws_route53_zone.xebia_public_dns.id}"
  name    = "swarm-worker${count.index + 1}.${var.public_subdomain}"
  type    = "A"
  ttl     = "300"

  records = [
    "${element(aws_instance.swarm-worker.*.public_ip, count.index)}",
  ]
}

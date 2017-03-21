#
# WORKER
#
########################################################################################################################

resource "aws_instance" "rexray" {
  count         = "1"
  ami           = "${data.aws_ami.ubuntu.id}"
  key_name      = "${aws_key_pair.access.key_name}"
  instance_type = "t2.medium"

  user_data = "${file("cloudinit.sh")}"

  associate_public_ip_address = true
  subnet_id                   = "${aws_subnet.rexray.id}"

  vpc_security_group_ids = [
    "${aws_security_group.allow_all.id}",
    "${aws_security_group.allow_prometheus.id}",
  ]

  tags {
    Name  = "${var.project_name} - rexray"
    Group = "${var.project_name}"
    Owner = "${var.owner}"
  }
}

resource "aws_subnet" "rexray" { 
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "${cidrsubnet(aws_vpc.main.cidr_block, 8, 9)}"

  tags {
    Name  = "${var.project_name} - rexray"
    Group = "${var.project_name}"
    Owner = "${var.owner}"
  }
}

resource "aws_route_table_association" "rexray" {
  subnet_id      = "${aws_subnet.rexray.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route53_record" "rexray" {
  count   = "1"
  zone_id = "${aws_route53_zone.private.zone_id}"
  name    = "rexray.private"
  type    = "A"
  ttl     = "300"

  records = [
    "${element(aws_instance.rexray.*.private_ip, count.index)}",
  ]
}

resource "aws_route53_record" "rexray-public" {
  count   = "1"
  zone_id = "${data.aws_route53_zone.xebia_public_dns.id}"
  name    = "rexray.${var.public_subdomain}"
  type    = "A"
  ttl     = "300"

  records = [
    "${element(aws_instance.rexray.*.public_ip, count.index)}",
  ]
}

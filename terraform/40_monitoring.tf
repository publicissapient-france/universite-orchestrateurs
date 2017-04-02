resource "aws_instance" "prometheus" {
  count         = "${var.monitoring_count}"
  ami           = "${data.aws_ami.ubuntu.id}"
  key_name      = "${aws_key_pair.access.key_name}"
  instance_type = "t2.medium"

  user_data = "${file("cloudinit.sh")}"

  associate_public_ip_address = true
  subnet_id                   = "${aws_subnet.monitoring.id}"

  vpc_security_group_ids = [
    "${aws_security_group.allow_ssh.id}",
    "${aws_security_group.allow_public_app.id}",
    "${aws_security_group.allow_logs.id}",
    "${aws_security_group.allow_vpc.id}",
  ]

  root_block_device {
    volume_size = 20
  }

  tags {
    Name  = "${var.project_name} - prometheus ${count.index + 1}"
    Group = "${var.project_name}"
    Owner = "${var.owner}"
  }
}

resource "aws_route53_record" "prometheus-private" {
  count   = "${var.monitoring_count}"
  zone_id = "${aws_route53_zone.private.zone_id}"
  name    = "prometheus${count.index + 1}.private"
  type    = "A"
  ttl     = "300"
  records = ["${element(aws_instance.prometheus.*.private_ip, count.index)}"]
}

resource "aws_route53_record" "prometheus-public" {
  zone_id = "${data.aws_route53_zone.xebia_public_dns.id}"
  name    = "prometheus${count.index + 1}.${var.public_subdomain}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.prometheus.public_ip}"]
}

resource "aws_subnet" "monitoring" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "${cidrsubnet(aws_vpc.main.cidr_block, 8, 8)}"

  tags {
    Name  = "${var.project_name} - monitoring"
    Group = "${var.project_name}"
    Owner = "${var.owner}"
  }
}

resource "aws_route_table_association" "monitoring" {
  subnet_id      = "${aws_subnet.monitoring.id}"
  route_table_id = "${aws_route_table.public.id}"
}

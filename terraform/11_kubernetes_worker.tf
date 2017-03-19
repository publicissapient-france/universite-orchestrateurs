resource "aws_instance" "kubernetes-worker" {
  count         = "${var.kubernetes-worker_count}"
  ami           = "${data.aws_ami.ubuntu.id}"
  key_name      = "${aws_key_pair.access.key_name}"
  instance_type = "t2.medium"
  user_data     = "${file("cloudinit.sh")}"

  associate_public_ip_address = true
  subnet_id                   = "${aws_subnet.kubernetes-worker.id}"

  iam_instance_profile = "${aws_iam_instance_profile.kubernetes-worker.id}"

  vpc_security_group_ids = [
    "${aws_security_group.allow_all.id}",
    "${aws_security_group.allow_prometheus.id}",
  ]

  tags {
    Name  = "${var.project_name} - kubernetes worker ${count.index + 1}"
    Group = "${var.project_name}"
    Owner = "${var.owner}"
  }
}

resource "aws_subnet" "kubernetes-worker" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "${cidrsubnet(aws_vpc.main.cidr_block, 8, 7)}"

  tags {
    Name  = "${var.project_name} - kubernetes worker"
    Group = "${var.project_name}"
    Owner = "${var.owner}"
  }
}

resource "aws_route_table_association" "kubernetes-worker" {
  subnet_id      = "${aws_subnet.kubernetes-worker.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route53_record" "kubernetes-worker" {
  count   = "${var.kubernetes-worker_count}"
  zone_id = "${aws_route53_zone.private.zone_id}"
  name    = "kubernetes-worker${count.index + 1}.private"
  type    = "A"
  ttl     = "300"

  records = [
    "${element(aws_instance.kubernetes-worker.*.private_ip, count.index)}",
  ]
}

resource "aws_route53_record" "kubernetes-worker-public" {
  count   = "${var.kubernetes-worker_count}"
  zone_id = "${data.aws_route53_zone.xebia_public_dns.id}"
  name    = "kubernetes-worker${count.index + 1}.${var.public_subdomain}"
  type    = "A"
  ttl     = "300"
  records = ["${element(aws_instance.kubernetes-master.*.public_ip, count.index)}"]
}

resource "aws_iam_instance_profile" "kubernetes-worker" {
  name  = "${var.iam_prefix}_kubernetes_worker_profile"
  roles = ["${aws_iam_role.kubernetes_worker_role.name}"]

  provisioner "local-exec" {
    command = "sleep 90"
  }
}

resource "aws_iam_role" "kubernetes_worker_role" {
  name = "${var.iam_prefix}_kubernetes_worker_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "Service": "ec2.amazonaws.com"},
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "kubernetes_worker_policy" {
  name = "${var.iam_prefix}_kubernetes_worker_policy"
  role = "${aws_iam_role.kubernetes_worker_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["ec2:*"],
      "Resource": ["*"]
    },
    {
      "Effect": "Allow",
      "Action": ["elasticloadbalancing:*"],
      "Resource": ["*"]
    },
    {
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": "*"
    }
  ]
}
EOF
}

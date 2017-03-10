data "aws_route53_zone" "xebia_public_dns" {
  name = "aws.xebiatechevent.info."
}

resource "aws_elb" "marathonlb" {

  name = "marathonlb"

  # refactor this
  subnets = ["${aws_subnet.public.id}"]
  security_groups = ["${aws_security_group.allow_all.id}"]

  listener {
    instance_port = 80
    instance_protocol = "tcp"
    lb_port = 80
    lb_protocol = "tcp"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 5
    target = "TCP:80"
    interval = 5
    timeout = 4
  }

  instances = [
    "${aws_instance.mesos-worker.*.id}"]

  tags = {
    Owner = "${var.owner}"
  }
}

resource "aws_route53_record" "goapp" {
  zone_id = "${data.aws_route53_zone.xebia_public_dns.id}"
  name = "*.mesosuniv"
  type = "A"

  alias {
    name = "${aws_elb.marathonlb.dns_name}"
    zone_id = "${aws_elb.marathonlb.zone_id}"
    evaluate_target_health = true
  }
}

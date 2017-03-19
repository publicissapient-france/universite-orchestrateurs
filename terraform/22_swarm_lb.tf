resource "aws_route53_record" "swarm_lb" {
  zone_id = "${data.aws_route53_zone.xebia_public_dns.id}"
  name    = "*.swarm.${var.public_subdomain}"
  type    = "A"
  ttl     = "300"

  records = [
    "${aws_instance.swarm-master.*.public_ip}",
  ]
}

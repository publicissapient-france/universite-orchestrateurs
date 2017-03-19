resource "aws_security_group" "kubernetes_cluster" {
  vpc_id      = "${aws_vpc.main.id}"
  name_prefix = "mesos-starter-sg"
  description = "kubernetes cluster security group"

  tags {
    Name = "${var.project_name} - KubernetesCluster"
    KubernetesCluster = "${var.cluster_id}"
  }
}

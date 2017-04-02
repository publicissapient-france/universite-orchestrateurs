resource "aws_iam_instance_profile" "rexray-worker" {
  name  = "${var.iam_prefix}_rexray_worker_profile"
  roles = ["${aws_iam_role.rexray_worker_role.name}"]

  provisioner "local-exec" {
    command = "sleep 90"
  }
}

resource "aws_iam_role" "rexray_worker_role" {
  name = "${var.iam_prefix}_rexray_worker_role"

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

resource "aws_iam_role_policy" "rexray_worker_policy" {
  name = "${var.iam_prefix}_rexray_worker_policy"
  role = "${aws_iam_role.rexray_worker_role.id}"

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
      "Action": "s3:*",
      "Resource": "*"
    }
  ]
}
EOF
}

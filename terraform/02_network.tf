

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags {
    Name = "${var.project_name}"
    Owner = "${var.owner}"
  }
}

/* Internet gateway for the public subnet */
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.main.id}"
  tags {
    Name = "${var.project_name} - gateway"
  }
}

resource "aws_subnet" "public" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${cidrsubnet(aws_vpc.main.cidr_block, 8, 1)}"
  map_public_ip_on_launch = true
  depends_on = [
    "aws_internet_gateway.default"]
  tags {
    Name = "${var.project_name} - public"
    Group = "${var.project_name}"
    Owner = "${var.owner}"
  }
}

/* Routing table for public subnet */
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.main.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }
  tags {
    Name = "${var.project_name} - public route table"
  }
}

/* Associate the routing table to public subnet */
resource "aws_route_table_association" "public" {
  subnet_id = "${aws_subnet.public.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_main_route_table_association" "a" {
  vpc_id = "${aws_vpc.main.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_eip" "nat" {
  vpc = "true"
}

/* Nat gateway for private resource */
resource "aws_nat_gateway" "gw" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id = "${aws_subnet.public.id}"
}

/* Routing table for private subnet */
resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.main.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.gw.id}"
  }
  tags {
    Name = "${var.project_name} - private route table"
  }
}

resource "aws_route53_zone" "private" {
  name = "private"
  vpc_id = "${aws_vpc.main.id}"
  tags = {
    Name = "${var.project_name} - private zone"
    Owner = "${var.owner}"
  }
}

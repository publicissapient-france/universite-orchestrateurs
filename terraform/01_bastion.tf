//
//resource "aws_instance" "bastion" {
//  ami = "${data.aws_ami.ubuntu.id}"
//  key_name = "${aws_key_pair.access.key_name}"
//  instance_type = "t2.micro"
//
//  associate_public_ip_address = true
//  source_dest_check = false
//
//  tags = {
//    Name = "${var.project_name} - bastion"
//    Owner = "${var.owner}"
//  }
//
//  subnet_id = "${aws_subnet.public.id}"
//  vpc_security_group_ids = ["${aws_security_group.allow_ssh.id}"]
//}


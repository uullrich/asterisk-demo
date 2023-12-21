data "template_file" "bootstrap" {
  template = file("./bootstrap.tpl")
  vars = {
    instance_name       = "asterisk-demo"
    asterisk_version    = var.asterisk_version
    node_version        = var.node_version
    pw_phone_01         = var.endpoint_passwords["phone_01"]
    pw_phone_02         = var.endpoint_passwords["phone_02"]
    pw_phone_03         = var.endpoint_passwords["phone_03"]
    ari_password        = var.ari_password
    domain_contact_mail = var.domain_contact_mail
    domain_name         = var.domain_name
  }
}

resource "aws_instance" "asterisk" {
  ami                         = "ami-06dd92ecc74fdfb36" # Ubuntu Server 22.04 LTS in eu-central-1
  instance_type               = "t3.nano"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.pbx_network.id
  vpc_security_group_ids      = [aws_security_group.allow_asterisk.id, aws_security_group.allow_ssh.id, aws_security_group.allow_asterisk_webserver.id]
  key_name                    = var.aws_key_pair
  user_data_base64            = base64encode(data.template_file.bootstrap.rendered)

  root_block_device {
    volume_size = "20"
  }

  tags = {
    Environment = var.environment_name
    Name        = "Asterisk Demo"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = self.public_ip
    private_key = file(var.private_key_local_path)
  }

  provisioner "remote-exec" {
    inline = ["mkdir -p /home/ubuntu/asterisk/config", "mkdir -p /home/ubuntu/apache/config"]
  }

  provisioner "file" {
    source      = "../config/"
    destination = "/home/ubuntu/asterisk/config"
  }

  provisioner "file" {
    source      = "../apache/"
    destination = "/home/ubuntu/apache/config"
  }
}

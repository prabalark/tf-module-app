resource "aws_instance" "" {
  ami           = "ami-0b4f379183e5706b9"
  instance_type = var.instance_type
  subnet_ids    = var.subnet_ids
}

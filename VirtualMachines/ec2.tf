resource "aws_instance" "VMTest" {
  ami           = "ami-013f17f36f8b1fefb"
  instance_type = "t2.micro"

  tags = {
    Name = "VMTestUbuntu"
  }
}

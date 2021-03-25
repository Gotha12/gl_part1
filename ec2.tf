resource "aws_instance" "VMTest" {
  ami           = "ami-02701bcdc5509e57b"
  instance_type = "t2.micro"

  tags = {
    Name = "VMTestUbuntu"
  }
}

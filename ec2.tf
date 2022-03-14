resource "aws_instance" "web" {
  ami           = "ami-0231217be14a6f3ba"
  instance_type = "t3.micro"

  tags = {
    Name = "HelloWorldssss"
  }
}
resource "aws_s3_bucket" "lab-keys-dev" {
  bucket = "lab-keys-devv-${random_pet.aumentarnamebucket.id}-${var.id_s3}"
  acl    = "private"

  tags = local.tags
}


resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-lock2"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}


#resource "aws_s3_bucket_object" "object" {
#  bucket = aws_s3_bucket.lab-keys-dev.bucket
#  key    = "scripts/${local.name_file}"
#  source = "/home/local/CONDUCTOR/m.silva/Documentos/VSCODE/${local.name_file}"

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  #etag = filemd5("/home/local/CONDUCTOR/m.silva/Documentos/VSCODE/${local.name_file}")
#}


resource "aws_s3_bucket" "tfstate-backend" {
  bucket = "tfstate-backend-2342342342342346"
  acl    = "private"

  versioning {
    enabled = true
  }
}
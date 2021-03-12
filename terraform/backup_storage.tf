resource "aws_s3_bucket" "hans_project_bucket" {
  bucket = "hans-project-hanibrown-bucket"
  tags = {
    Name  = "hans-project-bucket"
  }
}

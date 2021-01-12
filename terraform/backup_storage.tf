resource "aws_s3_bucket" "spoon_project_bucket" {
  bucket = "spoon-project-hanibrown-bucket"
  tags = {
    Name  = "spoon-project-bucket"
  }
}
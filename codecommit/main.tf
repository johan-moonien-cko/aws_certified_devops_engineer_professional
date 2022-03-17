resource "aws_codecommit_repository" "test" {
    repository_name = "my-webpage"
    description = "My first code commit repository"
}
resource "aws_s3_bucket" "mybucket" {
    bucket = "johan-cicd-devops"
    force_destroy = true
}
resource "aws_ecr_repository" "this" {
  name = var.name
}

resource "aws_ecr_repository_policy" "this" {
  repository = aws_ecr_repository.this.name

  policy = templatefile("${path.module}/policy.json", {
    aws_account = var.aws_account
  })
}

resource "aws_ecr_lifecycle_policy" "this" {
  repository = aws_ecr_repository.this.name

  policy = file("${path.module}/lifecycle-policy.json")
}

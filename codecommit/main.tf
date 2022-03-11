resource "aws_codecommit_repository" "test" {
    repository_name = "my-webpage"
    description = "My first code commit repository"
}

resource "aws_iam_policy" "policy" {
    name = "CannotPushToMasterInCodeCommit"
    path = "/"
    description = "Policy to limit pushes and merges to master branch in CodeCommit"

    policy = jsonencode ({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Deny",
            "Action": [
                "codecommit:GitPush",
                "codecommit:DeleteBranch",
                "codecommit:PutFile",
                "codecommit:MergeBranchesByFastForward",
                "codecommit:MergeBranchesBySquash",
                "codecommit:MergeBranchesByThreeWay",
                "codecommit:MergePullRequestByFastForward",
                "codecommit:MergePullRequestBySquash",
                "codecommit:MergePullRequestByThreeWay"
            ],
            "Resource": "arn:aws:codecommit:eu-west-1:528130383285:my-webpage",
            "Condition": {
                "StringEqualsIfExists": {
                    "codecommit:References": [
                        "refs/heads/main", 
                        "refs/heads/prod",
                        "refs/heads/master"
                     ]
                },
                "Null": {
                    "codecommit:References": "false"
                }
            }
        }
    ]
})
}
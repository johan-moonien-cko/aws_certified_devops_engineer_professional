resource "aws_vpc" "myvpc" {
    cidr_block = "10.10.0.0/16"

    tags = {
        Name = var.myvpc_name
    }
}

resource "aws_internet_gateway" "myigw" {
    vpc_id = aws_vpc.myvpc.id

    tags = {
        Name = var.myigw_name
    }
}

resource "aws_route_table" "mypublic_route_table" {
    vpc_id = aws_vpc.myvpc.id

    tags = {
      Name = var.mypublic_route_table_name
    }
}

resource "aws_route" "mypublic_route" {
  route_table_id = aws_route_table.mypublic_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.myigw.id
}

resource "aws_subnet" "mypublic_subnet" {
  vpc_id = aws_vpc.myvpc.id
  cidr_block = "10.10.0.0/24"
  availability_zone = "eu-west-1a"

  tags = {
      Name = var.mypublic_subnet_name
  }
}

resource "aws_route_table_association" "mypublic_route_table_assoc" {
  subnet_id = aws_subnet.mypublic_subnet.id
  route_table_id = aws_route_table.mypublic_route_table.id
}

resource "aws_security_group" "mysg" {
  name = "sgtest"
  description = "Allow SSH inbound traffic"
  vpc_id = aws_vpc.myvpc.id
  
  ingress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["102.118.153.19/32"]
      description = "johan home"
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
      Name = var.mysg_name
  }
}

resource "aws_instance" "myserver" {
    ami = "ami-0069d66985b09d219"
    key_name = "syseng"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.mypublic_subnet.id
    vpc_security_group_ids = [aws_security_group.mysg.id]
    associate_public_ip_address = true
    iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

    tags = {
        Name = var.myserver_name
    }
}

resource "aws_key_pair" "mykeypair" {
    key_name = "syseng"
   public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCSneB2f8aZXxdrii1i2im4RccEljqaGWRL6wH1JGxQN2alynCzp8un5TIWHhOTyLkwi/9i7dTNndj3uNtNYf4P8dDUij2TbUXy5PpxZBA2NLzSFJmLfYKXEIHeq/qkyJtQlNpa53fbXHf5B1m9I9ngjnmML6UTpsFgEYOg6p0jeBb65GSHwE14HJSQ96bDNdEyxGLYPt51BxKnyULRoCOgIRfu0wouIQdiZ7cl3drloWkV25D7ZAPyfsFHSdAeEB9dbbkhiXxsiJ2EJQ4MaoIsz7HLrLwi2PnpkssqJ/nJdKBWX6TwAcJlydO0XEG9n5BAJfRl0epKBMaUCARxHbtj"
}

resource "aws_iam_policy" "ec2_policy" {
  name = "ec2_policy"
  path = "/"
  description = "Policy to provide permission to EC2"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:Get*",
                "s3:List*",
                "s3-object-lambda:Get*",
                "s3-object-lambda:List*"
            ],
            "Resource": "*"
        }
    ]
  })
}

resource "aws_iam_role" "ec2_role" {
    name = "EC2RoleForCodeDeploy"

    assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sts:AssumeRole"
            ],
            "Principal": {
                "Service": [
                    "ec2.amazonaws.com"
                ]
            }
        }
    ]
    })
}

resource "aws_iam_policy_attachment" "ec2_policy_role" {
    name = "ec2_attachment"
    roles = [aws_iam_role.ec2_role.name]
    policy_arn = aws_iam_policy.ec2_policy.arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_profile"
  role = aws_iam_role.ec2_role.name
}


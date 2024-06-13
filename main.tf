data "aws_ami" "amazon" {
  most_recent = true
  owners      = ["self", "amazon"]

  filter {
    name   = "state"
    values = ["available"]
  }

  filter {
    name = "name"
    # al2023-ami-kernel-default-x86_64
    values = ["al2023-ami*kernel*x86_64"]
  }
}

data "aws_vpc" "vpc" {
  default = true
}


resource "aws_instance" "info_cost_ec2" {
  ami           = data.aws_ami.amazon.id
  instance_type = "t3.medium"

  tags = {
    Name = "CloudCuddler_EC2"
  }
}

resource "aws_instance" "info_cost_mec2" {
  ami           = data.aws_ami.amazon.id
  instance_type = "m5.xlarge"

  tags = {
    Name = "CloudCuddler_EC2_xLarge"
  }
}

resource "aws_ebs_volume" "info_cost_ebs" {
  availability_zone = "us-east-1a"
  size              = 150
}

resource "aws_s3_bucket" "info_cost_s3" {
  bucket = "851725606375_info_cost_s3"
}

resource "aws_subnet" "public_sub" {
  vpc_id                  = data.aws_vpc.vpc.id
  cidr_block              = "172.31.197.0/28"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
}

data "aws_internet_gateway" "igw" {
  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.vpc.id]
  }
}

# Route table

resource "aws_route_table" "rt" {
  vpc_id = data.aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_internet_gateway.igw.id
  }
}

#Route-table-associate

resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.public_sub.id
  route_table_id = aws_route_table.rt.id
}

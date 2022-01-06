resource "aws_vpc" "tg_test" {
  cidr_block              = local.cidr
  enable_dns_hostnames    = true

  tags = {
    Name                  = local.name
  }
}

resource "aws_internet_gateway" "tg_gw" {
  vpc_id                  = aws_vpc.tg_test.id

  tags = {
    Name                  = "${local.vpc-name}-gw"
  }
}

resource "aws_subnet" "public" {
  depends_on              = [aws_internet_gateway.tg_gw]
  availability_zone       = var.zones[count.index]

  count                   = var.subnets-count

  vpc_id                  = aws_vpc.tg_test.id
  cidr_block              = var.public_subnets[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name                  = "${var.vpc-name}-public"
  }
}

resource "aws_subnet" "private" {
  depends_on              = [aws_internet_gateway.tg_gw]
  availability_zone       = var.zones[count.index]

  count                   = var.subnets-count

  vpc_id                  = aws_vpc.tg_test.id
  cidr_block              = var.private_subnets[count.index]

  tags = {
    Name                  = "${var.vpc-name}-private"
  }
}

resource "aws_route_table" "public" {
  depends_on              = [aws_subnet.public]

  vpc_id                  = aws_vpc.tg_test.id

  route {
    cidr_block            = "0.0.0.0/0"
    gateway_id            = aws_internet_gateway.tg_gw.id
  }

  tags = {
    Name                  = "${var.vpc-name}-public-route"
  }
}

resource "aws_route_table_association" "public" {
  count                   = var.subnets-count
  subnet_id               = element(aws_subnet.public.*.id, count.index)
  route_table_id          = aws_route_table.public.id
}

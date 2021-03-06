
# ==============================================================================
# Terraform - From zero to certified professionnal
#
# Provision:
#   - vpc
#   - internet gateway
#   - XX public subnets
#   - XX private subnets
#   - XX nat gateways in public subnets to give internet access from private subnets
#
# developped by Guillaume Penaud
# ==============================================================================

# ==============================================================================
# DATA
# ==============================================================================

data "aws_availability_zones" "available" {}

# ==============================================================================
# RESOURCES
# ==============================================================================

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags       = merge(var.tags, { name = "${var.environment}-vpc" })
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = merge(var.tags, { name = "${var.environment}-vpc" })
}

resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags                    = merge(var.tags, { name = "${var.environment}-public-subnet-${count.index + 1}" })
}

resource "aws_route_table" "public_subnets" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = merge(var.tags, { name = "${var.environment}-route-public-subnets" })
}

resource "aws_route_table_association" "public_routes" {
  count          = length(aws_subnet.public_subnets[*].id)
  route_table_id = aws_route_table.public_subnets.id
  subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
}

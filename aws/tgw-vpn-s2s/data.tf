data "aws_route_tables" "a" {
  for_each = toset(var.pm4ml_routes_table_names[0])
  filter {
    name   = "tag:Name"
    values = [each.value]
  }

}

data "aws_route_tables" "b" {
  for_each = toset(var.pm4ml_routes_table_names[1])
  filter {
    name   = "tag:Name"
    values = [each.value]
  }

}
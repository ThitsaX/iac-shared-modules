data "aws_route_tables" "all" {
  for_each = toset(var.pm4ml_routes_table_names)
  filter {
    name   = "tag:Name"
    values = [each.value]
  }

}

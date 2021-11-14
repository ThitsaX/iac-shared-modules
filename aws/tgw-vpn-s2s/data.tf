data "aws_route_tables" "all" {
  for_each = var.route_table_name
  filter {
    name   = "tag:Name"
    values = [each.value]
  }

}

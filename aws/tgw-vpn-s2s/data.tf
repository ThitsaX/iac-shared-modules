data "aws_route_tables" "a" {

  filter {
    name   = "tag:Name"
    values = [element(var.pm4ml_routes_table_names,0)]
  }

}

data "aws_route_tables" "b" {

  filter {
    name   = "tag:Name"
    values = [element(var.pm4ml_routes_table_names,1)]
  }

}
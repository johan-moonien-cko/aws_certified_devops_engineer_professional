variable "myvpc_name" {
  type = string
  default = "johan_test_vpc"
}

variable "myigw_name" {
  type = string
  default = "test_igw"
}

variable "mypublic_route_table_name" {
  type = string
  default = "test_route_table"
}

variable "mypublic_subnet_name" {
  type = string
  default = "testpub_subnet"
}

variable "mysg_name" {
  type = string
  default = "johan-sg-test"
}

variable "myserver_name" {
  type = string
  default = "sys-eng-test-server01"
}

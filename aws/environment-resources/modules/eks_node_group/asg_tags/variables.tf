variable "asg_name" {
  type = string
}

variable "node_group_taints" {
  type = set(any)
}

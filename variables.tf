# Setting variables via command lines
  # terraform apply -var="<name_of_variable=value"
  # terraform apply -var='<name_of_variable_list=["value_1","value_2"]'
  # terraform apply -var-file="variables.tf"

# Setting variables
  # Name tags
variable "name" {
  type = string
  default = "eng48-harry-li-node-sample-app"
}
  # AMI - instance not required currently 28.01.2019
#variable "ami_nodesample" {
#  type = string
#  default = "ami-0d8e5cfe85e85b81b"
#}

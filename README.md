#ID304112 - System Administration - Portfolio 1 Code

Terraform definition files to set up a load balancer and n-amount of Ubuntu VMs in Azure.
The amount of VMs is defined as the variable "instance_count" in the file variables.tf.

1. The cloud provider is defined in provider.tf
1. Shared network infrastructure is defined in shared_network.tf
1. The load balancer and the VMs, along with their IP and NIC definitions are defined in servers_plus_network.tf
1. Shared variables defined in variables.tf

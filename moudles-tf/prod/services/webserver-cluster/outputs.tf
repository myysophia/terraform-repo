output "alb_dns_name" {
  # (1)  Output the DNS name of the load balancer so that consumers of this module know how to access the cluster
  #  via the load balancer URL (e.g., http://webserver-cluster-1234567890.us-east-2.elb.amazonaws.com)
  value       = module.webserver_cluster.alb_dns_name 
  description = "The domain name of the load balancer"
}

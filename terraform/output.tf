output "service_name" {
  value = "${aws_ecs_service.main.name}"
}

output "cluster_name" {
  value = "${aws_ecs_cluster.main.name}"
}

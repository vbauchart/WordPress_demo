# WordPress_demo
Terraform + Ansible deployment for WordPress server on AWS EC2 instances

##Requirements
0) Using Terraform create simple AWS resources(EC2 instances within custom VPC) for this deployment.
1) Using Ansible create an automated provision scenario, which deploys a highly available WordPress website.
2) Stack is - Percona MySQL on a separate server, two application backends, and Traefik as a proxy server.
3) It should be run on Debian 10, using security best practices.
4) Avoid vendor lock-ins and be sure the scenario is flexible for deployment to any cloud provider.
5) Keep used secrets in the repository in a secure way.
6) Make sure your README tells us how to run it.

##AWS Architecture
AWS Architecture due to Requirement #2
![AWS Architecture](docs/WordPress_demo.drawio.svg)
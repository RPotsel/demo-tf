yc_token  = ""
yc_cloud_id  = "b1gm04d20fit9ltelv1p"
yc_folder_id = "b1gu9vr18o6v8qc41svt"
family_images_linux = "ubuntu-2004-lts"
dns_zone  = "demo-zone"

vpc = {
  name = "demo-project"
  subnets = [{
    name   = "stage-a"
    zone   = "ru-central1-a"
    cidr4  = ["192.168.1.0/24"]
    labels = { env = "stage" }
  }]
  labels = { env = "demo-project" }
}

sgs = [
  {
    name = "k8s-main-sg"
    description = "Security group for the Managed Service for Kubernetes cluster and nodes"
    egress = [{
      description = "The rule allows all outgoing traffic"
      protocol    = "ANY"
      cidr4       = ["0.0.0.0/0"]
      from_port   = 0
      to_port     = 65535
    }]
    ingress = [{
      description = "The rule allows availability checks from the load balancer's range of addresses"
      protocol    = "TCP"
      predefined  = "loadbalancer_healthchecks" # The load balancer's address range.
      from_port   = 0
      to_port     = 65535
    },
    {
      description = "The rule allows the master-node and node-node interaction within the security group"
      protocol    = "ANY"
      predefined  = "self_security_group"
      from_port   = 0
      to_port     = 65535
    },
    {
      description = "The rule allows the pod-pod and service-service interaction"
      protocol    = "ANY"
      cidr4       = ["192.168.0.0/24","192.168.1.0/24"]
      from_port   = 0
      to_port     = 65535
    },
    {
      description = "The rule allows receipt of debugging ICMP packets from internal subnets"
      protocol    = "ICMP"
      cidr4       = ["192.168.0.0/24","192.168.1.0/24"]
    },
    {
      description = "The rule allows connection to Kubernetes API on 6443 port from the Internet"
      protocol    = "TCP"
      cidr4       = ["0.0.0.0/0"]
      port        = 6443
    },
    {
      description = "The rule allows connection to Kubernetes API on 443 port from the Internet"
      protocol    = "TCP"
      cidr4       = ["0.0.0.0/0"]
      port        = 443
    },
    {
      description = "The rule allows connection to secify NodePort"
      protocol    = "TCP"
      cidr4       = ["0.0.0.0/0"]
      from_port   = 30000
      to_port     = 32767
    },
    {
      description = "SSH"
      protocol    = "TCP"
      cidr4       = ["0.0.0.0/0"]
      port        = 22
    }]
  },
]

vms = [
  {
    names     = ["control-stage-01"]
    subnet    = "stage-a"
    nat       = true
    cores     = 2
    fraction  = null
    memory    = 2
    disk_size = 20
    labels    = { env = "stage", group_stage_1 = "kube_control_plane", group_stage_2="etcd", group_stage_3 = "k8s_cluster" }
    sgs       = ["k8s-main-sg"]
  },
  {
    names     = ["ingress-stage-01"]
    subnet    = "stage-a"
    nat       = true
    cores     = 2
    fraction  = 20
    memory    = 2
    disk_size = 20
    labels    = { env = "stage", group_stage_1 = "kube_ingress", group_stage_2 = "kube_node", group_stage_3 = "k8s_cluster" }
    sgs       = ["k8s-main-sg"]
  },
  {
    names     = ["worker-stage-01", "worker-stage-02"]
    subnet    = "stage-a"
    nat       = true
    cores     = 2
    fraction  = 20
    memory    = 4
    disk_size = 20
    labels    = { env = "stage", group_stage_1 = "kube_node", group_stage_2 = "k8s_cluster" }
    sgs       = ["k8s-main-sg"]
  },
]

lb = [
  {
    name = "k8s-stage"
    instances = ["ingress-stage-01"]
    port = 80
  },
]

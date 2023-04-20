yc_token  = ""
yc_cloud_id  = "b1gm04d20fit9ltelv1p"
yc_folder_id = "b1gu9vr18o6v8qc41svt"
family_images_linux = "ubuntu-2004-lts"
dns_zone  = "demo-zone"

vpc = {
  name = "demo-project"
  subnets = [{
    name   = "dev-a"
    zone   = "ru-central1-a"
    cidr4  = ["192.168.0.0/24"]
    labels = { env = "dev" }
  }]
  labels = { env = "demo-project" }
}

sgs = [
  {
    name = "dev-sg"
    description = "Developer security groups"
    egress = [{
      description = "any"
      protocol    = "ANY"
      cidr4       = ["0.0.0.0/0"]
    }]
    ingress = [{
      description = "ext-http"
      protocol    = "TCP"
      cidr4       = ["0.0.0.0/0"]
      port        = 80
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
    names     = ["dev"]
    subnet    = "dev-a"
    nat       = true
    cores     = 2
    fraction  = 20
    memory    = 4
    disk_size = 20
    labels    = { env = "dev", group_dev_1 = "jenkins", group_dev_2 = "nginx", group_dev_3 = "docker", group_dev_4 = "atlantis", group_stage_1 = "jenkins", group_prod_1 = "jenkins" }
    sgs       = ["dev-sg"]
  },
]

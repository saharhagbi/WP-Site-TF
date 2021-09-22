variable "sg-rules" {
  default = [
    { # 1
      port             = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
    }, # 2
    {
      port             = 80
      protocol         = "tcp"
      cidr_blocks      = []
      ipv6_cidr_blocks = ["::/0"]
    }, # 3
    {
      port             = -1
      protocol         = "icmpv6"
      cidr_blocks      = []
      ipv6_cidr_blocks = ["::/0"]
    }, # 4
    {
      port             = 443
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
    }, # 5
    {
      port             = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
    }, # 6
    {
      port             = -1
      protocol         = "icmp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
    }, # 7
    {
      port             = 443
      protocol         = "tcp"
      cidr_blocks      = []
      ipv6_cidr_blocks = ["::/0"]
    },
  ]
}

# variable "password" {
#   default   = "admin123"
#   sensitive = true
# }

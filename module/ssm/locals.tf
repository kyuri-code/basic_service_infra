locals {
  project_prefix = "study-basic-service"

  # インスタンス情報
  ami           = "ami-09cbdbe945bc01b52" // Amazon Linux 2
  instance_type = "t2.micro"

  # セキュリティグループ用
  my_ip = "124.33.254.162/32" // 自社VPNのIP

  # SSH接続時の情報
  ssh_key_path = "~/.ssh/study-basic-service.pub"
  key_name     = "study-basic-service"
}
locals {
  project_prefix = "study-basic-service"

  # インスタンス情報
  ami           = "ami-0a07ff89aacad043e" // UbuntuのAMI 無料枠 Ubuntu Server 24.04 LTS
  instance_type = "t2.small"
  instance_type_3c = "t3.small"

  # セキュリティグループ用
  my_ip = "124.33.254.162/32" // 自社VPNのIP

  # SSH接続時の情報
  ssh_key_path = "~/.ssh/study-basic-service.pub"
  key_name     = "study-basic-service"
}
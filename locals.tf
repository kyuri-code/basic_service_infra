locals {
  # 共通のプレフィックス
  project_prefix = "xxxxxxxxxx"

  # 環境情報
  region = "ap-northeast-3" //大阪リージョン

  # 共通の定義
  common_tags = {
    Project     = "xxxxxxxxxx"
    Owner       = "xxxxxxxxxx"
    Environment = var.environment
  }
}

## 目的
- 基本的なWEB - APIサーバの構成の環境を構築し、ネットワークのつながりを学習するための環境です。
- AWSリソースはサードパーティ製のIaCツールのTerraformを使用します。
- Webサーバには単純なhtmlファイルを使用します。
- APIサーバはPythonとFastAPIを用いて手軽にAPIサーバを立ち上げます。

## 使用技術一覧
![Linux](https://img.shields.io/badge/Linux-green)
![Terraform](https://img.shields.io/badge/Terraform-5.9.0-blueviolet)
![HTML](https://img.shields.io/badge/HTML-5.0-orange)
![Python](https://img.shields.io/badge/Python-3.10-blue)
![FastAPI](https://img.shields.io/badge/FastAPI-blue)

## 前提条件
- Windows端末にてWSL2が使用可能な状態であること。
- AWSのIAMユーザを保持していること。

## 制約
- **Windows端末を利用する際はWSL2の環境で実行してください。**  
  *PowerShellやコマンドプロンプトでの操作は動作の保証はできません。*

- **AWSリソースの環境を作成したら必ずリソースの後始末をお願いします。**  
  *リソース利用料がかかってしまいます。*

## Terraformについて
- インフラストラクチャをコードとして管理できるツールです。これにより、クラウドリソースやその他のインフラを宣言的に定義し、管理することができます。
- 公式サイト
  - [Terraform公式サイト](https://www.terraform.io/)

## ディレクトリ構成
```shell
.
├── app : アプリケーション
│   ├── api
│   │   ├── main.py
│   │   ├── requirements.txt
│   │   └── setup_fastapi.sh
│   ├── client
│   │   ├── capture_packet.py
│   │   └── client.py
│   ├── cp_installer.sh
│   ├── front
│   │   ├── index.html
│   │   ├── nginx.conf
│   │   └── setup_nginx.sh
│   └── tmp
│       ├── index.html
│       └── nginx.conf
├── module : awsの各リソース定義ファイル
│   ├── ec2
│   │   ├── ec2.tf
│   │   ├── locals.tf
│   │   └── variables.tf
│   └── vpc
│       ├── locals.tf
│       ├── outputs.tf
│       ├── variables.tf
│       └── vpc.tf
├── environment.tfvars
├── locals.tf
├── main.tf: 
├── output.tf
└── varibales.tf
```

## 環境の立ち上げ手順

### 各種ツールインストール
#### Terraform
- 下記サイトの[Linux]の項を参照して、インストールしてください。
- [Terraformインストール](https://developer.hashicorp.com/terraform/install?product_intent=terraform)

#### AWS CLI
- 下記のサイトの[Linux]の項を参照して、インストールしてください。
- [AWS CLIインストール](https://docs.aws.amazon.com/ja_jp/cli/latest/userguide/getting-started-install.html)

#### python
- 下記でダウンロードできるはず。。。
```
sudo apt update
sudo apt install python3.10
```

### キー生成
#### SSHキーの生成
```
ssh-keygen -t rsa -b 2048 -f ~/.ssh/sample.pem
# sample.pemとsample.pem.pubが作成される
# sample.pubは公開鍵となっている。
```

### 変数変更
#### 変数設定の変更
- 一部の.tfファイルのうち、設定変更が必要な項目があります。
  - /locals.tf
    - project_prefix : 各リソースの名前に付くプレフィックス
      - ec2なら、"[project_prefix]-ec2"という名前が割り当てられる。
    - region : リソースを構築したいリージョン。デフォルトは大阪。
    - common_tags内のProject : 何でも大丈夫です。[project_prefix]と同じ値にしています。
    - common_tags内のOwner : 何でも大丈夫です。自身の名前を割り当てています。
    ```shell
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
    ```
  - /module/ec2/locals.tf
    - project_prefix
    - my_ip : 自社VPNのIPを設定。VPN繋いだ状態でgoogle検索にて「what is my ip」と検索すると分かります。
    - ssh_key_path : ssh-keygenで作成したkeyファイル名(拡張子.pubの方)
    - key_name : ssh-keygenで作成したkeyファイル名(拡張子なしの名前)
    ```shell
        locals {
            project_prefix = "xxxxxxxxxx"

            # インスタンス情報
            ami            = "ami-09cbdbe945bc01b52" // Amazon Linux 2
            instance_type  = "t2.micro"

            # セキュリティグループ用
            my_ip          = "xxx.xxx.xxx.xxx/32" // 自社VPNのIP
            
            # SSH接続時の情報
            ssh_key_path   = "~/.ssh/xxxxxxxxxx.pub"
            key_name       = "xxxxxxxxxx"
        }
    ```
  - /module/vpc/locals.tf
    - project_prefix
    - az : vpcを配置するavailability_zoneの指定。regionを変更したら合わせて変更する必要あり。
      - デフォルトのregionが「ap-northeast-3」なので、「ap-northesat-3a」にしている。
    ```shell
        locals {
            project_prefix   = "xxxxxxxxxx"
            az               = "ap-northeast-3a"
            cidr_block_app   = "10.0.1.0/24"
            cidr_block_front = "10.0.2.0/24"
        }
    ```

### Terraformの実行で環境作成

#### terraformコマンドの実行
```
# terraform planで静的チェック
terraform plan
# ----> エラーがあるようならエラー内容を修正して再度planを実行
# terraform applyで実行
# 途中で実行するか聞かれるので"yes"を入力
terraform apply
```

#### appとfrontのec2インスタンスのパブリックDNS名の確認
- terraform.tfstateファイルから、作成したWebサーバ及びAPIサーバのDNS名を取得する。
  - terraform.tfstateファイルはterraform applyコマンドを実行したタイミングで出力される。リソースのメタ情報が記載されている。
  - resources.moduleが"module.ec2"内の"public_dns"キーに割り当たっているパブリックDNS名を取得する。
    - Web用とAPI用とそれぞれ二か所取得。
- /app/cp_install.shの変数に設定
  - api_server
  - front_server
  - key_file_name
  ```shell
    #!/bin/bash

    # 現在の作業ディレクトリの絶対パスを取得
    base_dir=$(dirname "$(realpath "$BASH_SOURCE")")

    # 各種変数定義
    username="ec2-user"
    cp_destination="/home/ec2-user"
    key_file_name="zzzzzzzzzz.pem"

    # EC2インスタンス作成後に下記のhost名を変更する。
    api_server="xxxxxxxxxx"
    front_server="yyyyyyyyyy"

    # 置換
    sed "s|{API_SERVER}|$api_server|g" "$base_dir/front/nginx.conf" > "$base_dir/tmp/nginx.conf"
    sed "s|{FRONT_SERVER}|$front_server|g" "$base_dir/front/index.html" > "$base_dir/tmp/index.html"

    # setup用のスクリプトをEC2に転送する
    sudo scp -i "~/.ssh/$key_file_name" "$base_dir/api/setup_fastapi.sh" "$username@$api_server:$cp_destination"
    sudo scp -i "~/.ssh/$key_file_name" "$base_dir/front/setup_nginx.sh" "$username@$front_server:$cp_destination"

    # サンプルアプリをEC2に転送する
    sudo scp -i "~/.ssh/$key_file_name" "$base_dir/api/main.py" "$username@$api_server:$cp_destination"
    sudo scp -i "~/.ssh/$key_file_name" "$base_dir/tmp/index.html" "$username@$front_server:$cp_destination"

    # nginxの設定ファイルの送信
    sudo scp -i "~/.ssh/$key_file_name" "$base_dir/tmp/nginx.conf" "$username@$front_server:$cp_destination"
  ```
### サーバの立ち上げ
#### リモートのEC2にアプリケーションを送信
- /app/cp_install.shを実行してリモートのEC2に資産をコピーする
  - 途中同意を求められるので、"yes"と入力。

#### 各種setupのスクリプトを実行
- TeraTermなどのツールでEC2にSSHログインする。
- ログインしたディレクトリ内に格納されている先ほどコピーしたsetup_fastapi.sh(setup_nginx.sh)を実行。
  - shellの実行権限がない場合は、実行権限を付与。
  ```shell
    # APIサーバにログイン後
    chmod 755 ./setup_fastapi.sh
    # Webサーバにログイン後
    chmod 755 ./setup_nginx.sh
  ```
- 上記を実行するとWebサーバとFastAPIサーバが立ち上がる。
- APIサーバはフォワードなので、プロセスの終了(CTRL+C)をしないと、終了しないので注意。
- WEBサーバはデーモンプロセスなので裏で常時起動している。

### 疎通確認
- ローカルのブラウザからWebサーバ用のEC2のパブリックDNS名をURLに貼り付けて遷移すると、フロント画面に遷移する。
- 下記のような画面が表示されたらOK

![](./images/web_top.png)

#### 各ボタンについて
- Post Data to API
  - KeyとValueに任意の値を入力して押下すると、APIサーバ側のインメモリDBに登録される。
- Get Data from API
  - APIサーバから"hello world"が返却されます。
- Get All Data from API
  - 「Post Data to API」で登録したデータが全て画面に表示されます。

## クライアントアプリについて

### 概要
- client.py
  - APIサーバに対してリクエストを送り、レスポンスを受け取るアプリです。
  - TCP/IPの内容が分かるような内容になっています。
  - 人間、手紙、郵便局というクラスを用いてどうやってデータが送受信されているかを見えるような作りになっています。
- capture_packet.py
  - client.pyで送信したパケットをキャプチャできるようになっています。
  - 使用時はフィルター条件に指定している送信先IPのパブリックIPを設定してください。
  ```python
    from scapy.all import sniff
    import logging

    ...中略

    def capture_tcp_packets():
        """TCPパケットをキャプチャして処理"""
        # フィルタ設定：TCPパケットで宛先がxxx.xxx.xxx.xxxのポート8000
        filter_str = "tcp and dst host xxx.xxx.xxx.xxx and dst port 8000"
        
        # パケットキャプチャの開始
        sniff(filter=filter_str, prn=packet_callback, store=False)

    if __name__ == "__main__":
        logging.info("Starting packet capture...")
        capture_tcp_packets()
        logging.info("Packet capture stopped.")
  ```

### 実行方法
- 先にcapture_packet.pyを実行しておく。ループで起動しているので、ユーザ側が任意で終了(CTRL+C)させる必要がある。
```shell
  python3 capture_packet.py
```
- そのあとにclient.pyを起動する。
```shell
  python3 client.py
```

- パケットの内容は起動したcapture_packet.pyの標準出力に表示されています。
- client.py側のログはログファイルまたは標準出力に表示された内容で確認できます。

## 最後に
**注意:**

大事なことなので2回言います。
- **AWSリソースの環境を作成したら必ずリソースの後始末をお願いします。**  
  *リソース利用料がかかってしまいます。*
#cloud-config
write_files:
  - path: /etc/ssl/nginx/nginx-repo.crt
    content: |
      -----BEGIN CERTIFICATE-----
      <<<-----  INSERT NGINX INSTANCE MANAGER CERTIFICATE HERE, GET FROM myf5.com ----->>>
      -----END CERTIFICATE-----
  
  - path: /etc/ssl/nginx/nginx-repo.key
    content: |
      -----BEGIN PRIVATE KEY-----
      <<<-----  INSERT NGINX INSTANCE MANAGER KEY FILE HERE, GET FROM myf5.com ----->>>
      -----END PRIVATE KEY-----
  
  - path: /etc/nginx-manager/nginx-instance-manager.lic
    content: |
      <<<-----  INSERT NGINX INSTANCE MANAGER LICENSE FILE HERE, GET FROM myf5.com ----->>>

runcmd:
  - sudo apt-get update
  - apt-get install -y apt-transport-https lsb-release ca-certificates
  - wget https://nginx.org/keys/nginx_signing.key
  - apt-key add nginx_signing.key
  - apt-get update
  - apt-get install -y nginx dirmngr
  - apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 8919F6BD2B48D754
  - echo "deb https://packages.clickhouse.com/deb stable main" | tee /etc/apt/sources.list.d/clickhouse.list
  - apt-get update
  - DEBIAN_FRONTEND=noninteractive apt-get install -y clickhouse-server clickhouse-client
  - service clickhouse-server start
  - printf "deb https://pkgs.nginx.com/nms/ubuntu focal nginx-plus\n" | tee /etc/apt/sources.list.d/nms.list
  - wget -q -O /etc/apt/apt.conf.d/90pkgs-nginx https://cs.nginx.com/static/files/90pkgs-nginx
  - apt-get update
  - apt-get install -y nms-instance-manager
  - systemctl start clickhouse-server
  - systemctl start nginx
  - systemctl enable nms-core
  - systemctl enable nms-dpm
  - systemctl enable nms-ingestion
  - systemctl enable nms
  - systemctl start nms
  - systemctl reload nginx
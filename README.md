# azureNginx


# This will create a Nginx Instance Manager(NIM) running on Ubuntu 20.04 and a PAYG Nginx Plus instance from the marketplace.


* You will need to update the cloud-init file which is located nginxPayg&nginxIM/cloudInitFiles/cloud-init_nginxIM.tpl
  * You can obtain a trial for Nginx Instance Manager from myF5.com
  * You will need to download a certificate, key, and license file from myF5.com, input the information into the cloud-init file
* Update *.tfvars with your variables specific to your environment
* Once NIM is running you will need to connect to the GUI at: https://<IP_address>/ui
* The initial username and password for NIM can be found in the /var/log/cloud-init-output.log of the NIM Ubuntu instance 
* The license file will need to be uploaded to the NIM instance, go to settings in the NIM GUI to upload license file


#NIM install guide --> https://docs.nginx.com/nginx-instance-manager/installation/


# I used the following article and associated repo as a base

Blog --> https://gmusumeci.medium.com/how-to-deploy-a-linux-vm-with-nginx-plus-or-enterprise-in-azure-using-terraform-6f7b5f25b5ab
Repo --> https://github.com/guillermo-musumeci/terraform-azure-vm-nginx-plus

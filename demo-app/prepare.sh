#!/usr/bin/env bash
set -euo pipefail

YC_TOKEN=$(yc iam create-token)
YC_CLOUD_ID=$(yc config get cloud-id)
YC_FOLDER_ID=$(yc config get folder-id)
PROJECT=demo-app
SERVICE_ACCOUNT=${PROJECT}-bucket-editor
DOMAIN_NAME=pinbit.ru

cert_request(){
  yc certificate-manager certificate request --name demo-cert --domains "*.$(DOMAIN_NAME)" --challenge dns
}

create_zone(){
	yc dns zone create --name demo-zone --zone $(DOMAIN_NAME). --public-visibility
	yc dns zone add-records --name demo-zone --record \
		"_acme-challenge.$(DOMAIN_NAME). 600 CNAME \
		$(yc cm certificate get demo-cert --format=json | jq -r ".id").cm.yandexcloud.net."

	yc dns zone add-records --name demo-zone --record "demo.stage.pinbit.ru. 200 CNAME k8s-stage.pinbit.ru."
	yc dns zone add-records --name demo-zone --record "demo.pinbit.ru. 200 CNAME k8s-prod.pinbit.ru."
	yc dns zone add-records --name demo-zone --record "grafana.pinbit.ru. 200 CNAME k8s-prod.pinbit.ru."
	yc dns zone add-records --name demo-zone --record "jenkins.dev.pinbit.ru. 200 CNAME dev.pinbit.ru."
	yc dns zone add-records --name demo-zone --record "atlantis.dev.pinbit.ru. 200 CNAME dev.pinbit.ru."
	# yc dns zone list-records --name demo-zone
}

create_network(){
	yc vpc network create \
    --name demo-project \
    --folder-id ${YC_FOLDER_ID} \
    --labels env=demo-project
 
  GW_ID=$(yc vpc gateway create default \
    --folder-id ${YC_FOLDER_ID} \
    --format json | jq -r .id)

  yc vpc route-table create nat_rt \
    --route destination=0.0.0.0/0,gateway-id=${GW_ID} \
    --network-name demo-project \
    --folder-id ${YC_FOLDER_ID}
}

create_bucket(){
  yc iam service-account create ${SERVICE_ACCOUNT} \
    --folder-id ${YC_FOLDER_ID} \
    --format json

  ACCESS_KEY=$(yc iam access-key create \
    --service-account-name ${SERVICE_ACCOUNT} \
    --folder-id ${YC_FOLDER_ID} \
    --format json)
  echo ${ACCESS_KEY}

  SERVICE_ACCOUNT_ID=$(echo ${ACCESS_KEY} | jq -r .access_key.service_account_id)
  ACCESS_KEY_ID=$(echo ${ACCESS_KEY} | jq -r .access_key.key_id)
  SECRET_ACCESS_KEY=$(echo ${ACCESS_KEY} | jq -r .secret)

  yc storage bucket create \
    --name  ${PROJECT}-tf-state\
    --max-size 5242880

  # https://cloud.yandex.ru/docs/storage/concepts/acl
  # ERROR: rpc error: code = Unimplemented desc = A header you provided implies functionality that is not implemented
  # yc storage bucket update --name ${PROJECT}-tf-state \
  #   --grants grant-type=grant-type-account,grantee-id=${SERVICE_ACCOUNT_ID},permission=permission-write

  yc resource-manager folder add-access-binding ${YC_FOLDER_ID} \
    --role storage.editor \
    --subject serviceAccount:${SERVICE_ACCOUNT_ID}

  yc resource-manager folder add-access-binding ${YC_FOLDER_ID} \
    --role kms.keys.encrypterDecrypter \
    --subject serviceAccount:${SERVICE_ACCOUNT_ID}

  export ACCESS_KEY_ID SECRET_ACCESS_KEY
  envsubst < "backend.cred.tmpl" > "backend.cred"
}

delete_zone(){
	yc dns zone delete --name demo-zone
}

delete_network(){
  yc vpc route-table delete --name nat_rt
  yc vpc gateway delete --name default
	yc vpc network delete --name demo-project
}

delete_bucket(){
    yc storage bucket delete --name  ${PROJECT}-tf-state
    yc iam service-account delete ${SERVICE_ACCOUNT} --folder-id ${YC_FOLDER_ID}
}

declare ACTION=$1

case $ACTION in
  "init")
    cert_request
    create_zone
    create_network
    create_bucket
    ;;
  "delete")
    delete_bucket
    delete_network
    delete_zone
    ;;
  *)
    "$@"
    ;;
esac

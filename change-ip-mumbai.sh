compartment_id=ocid1.tenancy.oc1..aaaaaaaabbhzzrbrqlito6dqevzd3zdyzjtsmnvxlodoqp57kidrdm2o7dya
availability_domain=QXep:AP-MUMBAI-1-AD-1
#get by "oci iam availability-domain list"

scope=AVAILABILITY_DOMAIN

DATA=$(/home/ubuntu/bin/oci network public-ip list \
	--compartment-id $compartment_id \
	--scope $scope \
	--availability-domain $availability_domain \
	--lifetime EPHEMERAL --all --profile MUMBAI | jq .data)
FDATA=$(echo $DATA | jq .[0])

public_ip=$(echo $FDATA | jq '."ip-address"')
echo current primary ip is $public_ip

public_ip_id=$(echo $(echo $FDATA | jq .id ) | tr -d '"')
private_ip_id=$(echo $(echo $FDATA | jq '."private-ip-id"') | tr -d '"')

echo ---deleting ip---
oci network public-ip delete \
	--public-ip-id $public_ip_id \
	--force --profile MUMBAI

echo ---adding new ip---
new_ip_data=$(oci network public-ip create \
	--compartment-id $compartment_id \
	--lifetime EPHEMERAL \
	--private-ip-id $private_ip_id \
	--profile MUMBAI | jq .data)

new_public_ip=$(echo $new_ip_data | jq '."ip-address"')

echo changed primary ip address to $new_public_ip


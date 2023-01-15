# Variables block 
resourceGroupName = "HTHQ-RG"
location="East US"
vnetName = "HTHQ-vnet"
subnetName = "HTHQ-DevSubnet"
pupIP = "HTHQvm_pip"
nsgName ="HTHQ-NSQ"
rule1 ="rule1_ssh"
vmNic = "vm1_nic"
vmName= "vm1"
size = "Standard_DS1_v2"
Admin= "azureuser"
DiskType = "Premium_LRS"
image= "CentOS 7.5"

#create a resource group
az group create -n $resourceGroupName -l $location
#Create a Vnet, The virtual network should have an address space of 10.10.0.0/16, Add one subnet to it with an 
#address range of 10.10.1.0/24 
az network vnet create \
 --name $vnetName \
 --resource-group $resourceGroupName \
 --address-prefixes 10.10.0.0/16 \
 --subnet-name $subnetName \
 --subnet-prefixes 10.10.1.0/24
#Create a public IP address that you will use to access your Azure VM via SSH later. Put it in the resource group 
# created and use static allocation for the public IP address.
az network public-ip create \
 --name $pupIP \
 --resource-group $resourceGroupName \
 --allocation-method Static
#Create a Network Security Group  that you will use to protect your Azure VM so that it is only accessible 
#via TCP port 22 inbound. Set the priority to 1001.
az network nsg create \
 --name $nsgName \
 --resource-group $resourceGroupName
# NSG Rule
az network nsg rule create \
 --name $rule1 \
 --nsg-name $nsgName \
 --resource-group $resourceGroupName \
 --priority 1001 \
 --source-address-prefixes '*' \
 --source-port-ranges 22 \
 --protocol Tcp \
 --destination-address-prefixes 10.10.1.0/24 \
 --destination-port-ranges 22 \
 --access Allow \
 --description "Accessable only on port 22 and protocol tcp"

# Create a Linux VM . You will first need to create a Network Interface Card
az network nic create \
--name $vmNic \ 
--resource-group $resourceGroupName \
--vnet-name $vnetName \
--subnet $subnetName \
--network-security-group $nsgName \
--public-ip-address $pupIP

##VM Name
az vm create \
 --name $vmName \
 --resource-group $resourceGroupName \
 --size $size \ 
 --admin-username $Admin \
 --authentication-type ssh \
 --generate-ssh-keys  \
 --nics $nicName \
 --storage-sku $disktype \
 --image $image 

#Install the NGINX web server on an existing Linux Virtual Machine
az vm run-command invoke \
 --resource-group $resourceGroupName \
 --name $vmName \
 --command-id RunShellScript \
 --scripts "sudo apt-get update && sudo apt-get install -y nginx" 

resource "azurerm_resource_group" "FADevOps" {
  name     = "FAthi2"
  location = "eastasia"
}

resource "azurerm_virtual_network" "FAnet" {
  name                = "FA-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.FADevOps.location
  resource_group_name = azurerm_resource_group.FADevOps.name
}

resource "azurerm_subnet" "FAsubnet" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.FADevOps.name
  virtual_network_name = azurerm_virtual_network.FAnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "pubIP" {
  name                    = "test-pip"
  location                = azurerm_resource_group.FADevOps.location
  resource_group_name     = azurerm_resource_group.FADevOps.name
  allocation_method       = "Static"

  tags = {
    environment = "test"
  }
}

resource "azurerm_network_interface" "FAni" {
  name                = "FA-nic"
  location            = azurerm_resource_group.FADevOps.location
  resource_group_name = azurerm_resource_group.FADevOps.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.FAsubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pubIP.id
  }
}

resource "azurerm_network_security_group" "FArule" {
  name                = "acceptanceTestSecurityGroup1"
  location            = azurerm_resource_group.FADevOps.location
  resource_group_name = azurerm_resource_group.FADevOps.name

  security_rule {
    name                       = "ruleFA"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "test"
  }
}

resource "azurerm_network_interface_security_group_association" "bound" {
  network_interface_id      = azurerm_network_interface.FAni.id
  network_security_group_id = azurerm_network_security_group.FArule.id
}

resource "azurerm_linux_virtual_machine" "VM" {
  name                = "VM-machine"
  resource_group_name = azurerm_resource_group.FADevOps.name
  location            = azurerm_resource_group.FADevOps.location
  size                = "Standard_B2s"
  admin_username      = "azureuser"
  custom_data = base64encode(file("scripts/init.sh"))
  network_interface_ids = [
    azurerm_network_interface.FAni.id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb = 30
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  tags = {
    "key"       = var.envname
    Environment = "dev sua"
  }
}

/////// add blob container resource 

resource "azurerm_storage_account" "fastorage13" {
  name                     = "fastorage13"
  resource_group_name      = "cloud-shell-storage-southeastasia"
  location                 = azurerm_resource_group.FADevOps.location
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "RAGRS"
  
  static_website {
    index_document = "index.html"
  }
}
 
resource "azurerm_storage_container" "webcontainer" {
  name                  = "web"
  storage_account_name  = azurerm_storage_account.fastorage13.name
  container_access_type = "blob"
}

resource "azurerm_storage_blob" "webblob" {
  for_each = fileset(path.module, "file_uploads/*")
 
  name                   = trim(each.key, "file_uploads/")
  storage_account_name   = azurerm_storage_account.fastorage13.name
  storage_container_name = azurerm_storage_container.webcontainer.name
  type                   = "Block"
  source                 = each.key
}


terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

terraform {
  backend "azurerm" {
    resource_group_name  = "cloud-shell-storage-southeastasia"
    storage_account_name = "fastorage12"
    container_name       = "state"
    key                  = "terraform.tfstate"
    static_website {
    index_document = "index.html"
  }
  }

}

provider "azurerm" {
  features {
  }
}





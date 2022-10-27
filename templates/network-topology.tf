############
# Hub VNet #
############

resource "azurerm_virtual_network" "hub-vnet" {
  name                = "hub-vnet"
  location            = azurerm_resource_group.hub-rg.location
  resource_group_name = azurerm_resource_group.hub-rg.name
  address_space       = ["10.1.0.0/21"]
}

resource "azurerm_subnet" "hub-azurefirewall-subnet" {
    name                    = "AzureFirewallSubnet"
    resource_group_name     = azurerm_resource_group.hub-rg.name
    virtual_network_name    = azurerm_virtual_network.hub-vnet.name
    address_prefixes        = ["10.1.0.0/26"]
}

resource "azurerm_subnet" "hub-applicationgateway-subnet" {
    name                    = "snet-applicationgateway"
    resource_group_name     = azurerm_resource_group.hub-rg.name
    virtual_network_name    = azurerm_virtual_network.hub-vnet.name
    address_prefixes        = ["10.1.0.64/26"]
}

##############
# Spoke VNet #
##############

resource "azurerm_virtual_network" "spoke-vnet" {
  name                = "spoke-vnet"
  location            = azurerm_resource_group.spoke-rg.location
  resource_group_name = azurerm_resource_group.spoke-rg.name
  address_space       = ["10.1.8.0/24"]
}

resource "azurerm_subnet" "spoke-workload-subnet" {
    name                    = "snet-workload"
    resource_group_name     = azurerm_resource_group.spoke-rg.name
    virtual_network_name    = azurerm_virtual_network.spoke-vnet.name
    address_prefixes        = ["10.1.8.0/24"]
}

##########################
# Peering hub <--> spoke #
##########################

resource "azurerm_virtual_network_peering" "hub-spoke" {
  name                              = "PEERING_HUB_TO_SPOKE"
  resource_group_name               = azurerm_resource_group.hub-rg.name
  virtual_network_name              = azurerm_virtual_network.hub-vnet.name
  remote_virtual_network_id         = azurerm_virtual_network.spoke-vnet.id
  allow_virtual_network_access      = true
  allow_forwarded_traffic           = true
  allow_gateway_transit             = false
  use_remote_gateways               = false
}

resource "azurerm_virtual_network_peering" "spoke-hub" {
  name                              = "PEERING_SPOKE_TO_HUB"
  resource_group_name               = azurerm_resource_group.spoke-rg.name
  virtual_network_name              = azurerm_virtual_network.spoke-vnet.name
  remote_virtual_network_id         = azurerm_virtual_network.hub-vnet.id
  allow_virtual_network_access      = true
  allow_forwarded_traffic           = true
  allow_gateway_transit             = false
  use_remote_gateways               = false
  }
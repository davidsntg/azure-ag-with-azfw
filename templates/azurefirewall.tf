
resource "azurerm_public_ip" "hub-azurefirewall-pip" {
  name = "AzureFirewall-pip"
  location = azurerm_resource_group.hub-rg.location
  resource_group_name = azurerm_resource_group.hub-rg.name
  
  allocation_method = "Static"
  sku = "Standard"
}

resource "azurerm_log_analytics_workspace" "azure_firewall_law" {
  name                = "AzureFirewall-logs"
  location            = azurerm_resource_group.hub-rg.location
  resource_group_name = azurerm_resource_group.hub-rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_firewall_policy" "hub-azfirewall-policy" {
  name                = "AzureFirewallPolicy"
  resource_group_name = azurerm_resource_group.hub-rg.name
  location            = azurerm_resource_group.hub-rg.location
  sku                 = "Premium"
  threat_intelligence_mode = "Off"
  
  # TO FIX
  /*
  insights {
    default_log_analytics_workspace_id = azurerm_log_analytics_workspace.azure_firewall_law.id
    enabled = true
    retention_in_days = 30
  }*/
}

resource "azurerm_firewall" "hub-azure-firewall" {
  name = "AzureFirewall"
  location = azurerm_resource_group.hub-rg.location
  resource_group_name = azurerm_resource_group.hub-rg.name
  sku_name = "AZFW_VNet"
  sku_tier = "Premium"
  firewall_policy_id = azurerm_firewall_policy.hub-azfirewall-policy.id
  
  ip_configuration {
    name = "fw-ipconfig"
    subnet_id = azurerm_subnet.hub-azurefirewall-subnet.id
    public_ip_address_id = azurerm_public_ip.hub-azurefirewall-pip.id
  }
 
}

resource "azurerm_monitor_diagnostic_setting" "azure_firewall_monitor" {
  name               = "AzureFirewallMonitorLogs"
  target_resource_id = azurerm_firewall.hub-azure-firewall.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.azure_firewall_law.id

  log {
    category = "AzureFirewallApplicationRule"
    enabled  = true

    retention_policy {
      days    = 0
      enabled = false
    }
  }

  log {
    category = "AzureFirewallNetworkRule"
    enabled  = true

    retention_policy {
      days    = 0
      enabled = false
    }
  }

  log {
    category = "AZFWFqdnResolveFailure"
    enabled  = true

    retention_policy {
      days    = 0
      enabled = false
    }
  }

  log {
    category = "AZFWIdpsSignature"
    enabled  = true

    retention_policy {
      days    = 0
      enabled = false
    }
  }

  log {
    category = "AZFWNatRule"
    enabled  = true

    retention_policy {
      days    = 0
      enabled = false
    }
  }

  log {
    category = "AZFWNatRuleAggregation"
    enabled  = true

    retention_policy {
      days    = 0
      enabled = false
    }
  }

  log {
    category = "AZFWThreatIntel"
    enabled  = true

    retention_policy {
      days    = 0
      enabled = false
    }
  }

  log {
    category = "AZFWNetworkRuleAggregation"
    enabled  = true

    retention_policy {
      days    = 0
      enabled = false
    }
  }

  log {
    category = "AZFWNetworkRule"
    enabled  = true

    retention_policy {
      days    = 0
      enabled = false
    }
  }
  
  log {
    category = "AzureFirewallDnsProxy"
    enabled  = true

    retention_policy {
      days    = 0
      enabled = false
    }
  }

  log {
    category = "AZFWFatFlow"
    enabled  = true

    retention_policy {
      days    = 0
      enabled = false
    }
  }

  log {
    category = "AZFWDnsQuery"
    enabled  = true

    retention_policy {
      days    = 0
      enabled = false
    }
  }

  log {
    category = "AZFWApplicationRuleAggregation"
    enabled  = true

    retention_policy {
      days    = 0
      enabled = false
    }
  }

  log {
    category = "AZFWApplicationRule"
    enabled  = true

    retention_policy {
      days    = 0
      enabled = false
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true

    retention_policy {
      days    = 0
      enabled = false
    }
  }
}
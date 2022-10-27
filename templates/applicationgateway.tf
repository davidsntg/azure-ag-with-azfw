resource "azurerm_public_ip" "hub-application-gateway-pip" {
  name                = "ApplicationGateway-pip"
  resource_group_name = azurerm_resource_group.hub-rg.name
  location            = azurerm_resource_group.hub-rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_application_gateway" "hub-application-gateway" {
  name                = "ApplicationGateway"
  resource_group_name = azurerm_resource_group.hub-rg.name
  location            = azurerm_resource_group.hub-rg.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.hub-applicationgateway-subnet.id
  }

  frontend_port {
    name = var.frontend_port_name // "myFrontendPort"
    port = 80
  }

  frontend_ip_configuration {
    name                 = var.frontend_ip_configuration_public_name 
    public_ip_address_id = azurerm_public_ip.hub-application-gateway-pip.id
  }

  frontend_ip_configuration {
    name                          = var.frontend_ip_configuration_private_name
    subnet_id                     = "${azurerm_subnet.hub-applicationgateway-subnet.id}"
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.1.0.72"
  }

  backend_address_pool {
    name = var.backend_address_pool_name //"myBackendPool"
    ip_addresses = [azurerm_network_interface.webapp-vm-nic.private_ip_address]
  }

  backend_http_settings {
    name                  = var.backend_http_setting_name //"myHTTPsetting"
    cookie_based_affinity = "Disabled"
    //path                  = "/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 20
    pick_host_name_from_backend_address = true
  }

  http_listener {
    name                           = var.public_listener_name
    frontend_ip_configuration_name = var.frontend_ip_configuration_private_name
    frontend_port_name             = var.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    priority                   = 100
    name                       = var.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = var.public_listener_name
    backend_address_pool_name  = var.backend_address_pool_name
    backend_http_settings_name = var.backend_http_setting_name
  }
}

resource "azurerm_monitor_diagnostic_setting" "azure_applicationgateway_monitor" {
  name               = "AzureApplicationGatewayMonitorLogs"
  target_resource_id = azurerm_application_gateway.hub-application-gateway.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.azure_firewall_law.id

  log {
    category = "ApplicationGatewayFirewallLog"
    enabled  = true

    retention_policy {
      days    = 0
      enabled = false
    }
  }

  log {
    category = "ApplicationGatewayAccessLog"
    enabled  = true

    retention_policy {
      days    = 0
      enabled = false
    }
  }

  log {
    category = "ApplicationGatewayPerformanceLog"
    enabled  = true

    retention_policy {
      days    = 0
      enabled = false
    }
  }
}
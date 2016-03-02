# vault service ip
resource "google_compute_address" "vault_service" {
    name = "vault-service"
}

output "vault_service_ip" {
    value = "${google_compute_address.vault_service.address}"
}

# vault server pool
resource "google_compute_target_pool" "vault" {
    name = "vault-pool"
    description = "vault server pool"
    #instances = [ "us-central1-a/vault-1","us-central1-a/vault-2","us-central1-a/vault-3" ]
    instances = ["${formatlist("%s/%s", google_compute_instance.vault.*.zone, google_compute_instance.vault.*.name)}"]

    # Not supported on google API: https://github.com/hashicorp/terraform/issues/4282
    # health_checks = [ "${google_compute_https_health_check.vault.name}" ]
}

/*
# Valt API did not have HEAD endpoint so there is no way to check, well not yet.
resource "google_compute_https_health_check" "vault" {
    name = "vault-health"
    port = "8200"
    request_path = "/v1/sys/health"
    check_interval_sec = 5
    timeout_sec = 5
}
*/

# bind the vault service ip to target pool
resource "google_compute_forwarding_rule" "vault_service" {
    name = "vault-service"
    description = "bind the vault service ip to target pool"
    target = "${google_compute_target_pool.vault.self_link}"
    ip_address = "${google_compute_address.vault_service.address}"
    ip_protocol = "TCP"
    port_range = "8200"
}



# Observability Proof of Concept (PoC)

This repository contains Terraform configurations to deploy a Google Kubernetes Engine (GKE) cluster with a comprehensive observability stack on Google Cloud Platform.

## Architecture Diagram

![Diagram](./diagram.png)

## Features

- **GKE Cluster**: Fully configured Kubernetes cluster with node pools
- **Networking**: VPC network and subnetwork configuration
- **Compute Resources**: Additional VM instances for testing
- **Observability Stack**:
  - Prometheus for metrics collection
  - Loki for log aggregation
  - Gatus for uptime monitoring
  - Grafana for visualization
- **Ingress**: NGINX ingress controller with TLS termination
- **DNS**: Automated DNS record management
- **Certificates**: Automatic TLS certificate provisioning via cert-manager

## Key Configuration

### Machine Types

```hcl
machine_type = {
  default = "e2-standard-2"  # For most workloads
  large   = "e2-standard-4"  # For resource-intensive applications
}
```

### Disk Sizes

```hcl
disk_size = {
  small = 20  # GB - For standard workloads
  large = 50  # GB - For storage-intensive applications
}
```

## Components

### Core Infrastructure

- GKE Cluster with node pools
- VPC Network and Subnets
- Compute Engine instances (Ubuntu 24.04 LTS)

### Monitoring Stack

- Prometheus (metrics) at `prometheus.poc-k8s.dados.rio`
- Loki (logs) at `loki.poc-k8s.dados.rio`
- Gatus (status pages) at `gatus.poc-vm.dados.rio`
- Grafana (dashboards) at `grafana.poc-vm.dados.rio`

### Supporting Services

- NGINX Ingress Controller
- cert-manager with Let's Encrypt integration
- Automated DNS records in `dados-rio` zone

## Prerequisites

- Google Cloud Platform account with:
  - DNS permissions for `dados-rio` zone
  - GKE and Compute Engine APIs enabled
- Terraform 1.0+
- gcloud CLI configured with proper permissions
- Infisical account for secret management with:
  - Service token
  - Environment profile
  - Secrets path configured
- [just](https://github.com/casey/just) CLI for command management (optional but recommended)

## Deployment

1. Clone this repository
2. Configure Infisical variables in `terraform.tfvars`:

   ```hcl
   infisical_address = "your-infisical-host"
   infisical_token   = "your-service-token"
   infisical_profile = "your-environment"
   infisical_path    = "your/secrets/path"
   bucket            = "your-gcs-bucket-name"
   ```

3. Initialize Terraform:

   ```bash
   just init
   ```

4. Review and apply:

   ```bash
   just plan
   just apply
   ```

## Accessing Services

After deployment, the following endpoints will be available:

- Prometheus: `https://prometheus.poc-k8s.dados.rio`
- Loki: `https://loki.poc-k8s.dados.rio`
- Gatus: `https://gatus.poc-k8s.dados.rio`
- Grafana: `https://grafana.poc-vm.dados.rio`

## Maintenance

To update the infrastructure:

```bash
just
```

To destroy all resources:

```bash
just destroy
```

## Troubleshooting

Common issues:

- DNS propagation delays (wait 5-10 minutes after deployment)
- Certificate provisioning (check cert-manager logs)
- Infisical secret permissions (verify token has read access)

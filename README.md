# my-cloud-app
# AWS EC2 + NGINX Deployment with Terraform & GitHub Actions

## Architecture
[Insert the architecture diagram image here]

## Stack
- **App**: Static HTML served by NGINX
- **Infra**: AWS EC2 (t2.micro, Free Tier)
- **IaC**: Terraform
- **CI/CD**: GitHub Actions

## Design Decisions
- **NGINX over Apache**: Lightweight, faster for static content, simpler config
- **t2.micro**: Free tier eligible, sufficient for a demo app
- **IAM Role with SSM**: Allows instance management without hardcoded credentials
- **Static HTML**: Keeps the app simple and focused on the infra/pipeline requirements

## Trade-offs
| Decision | Trade-off |
|---|---|
| t2.micro instance | Low cost but limited CPU burst; fine for demo |
| SSH deploy in CI/CD | Simple but exposes port 22; production would use SSM or S3 |
| Single AZ deployment | No high availability; acceptable for this assessment |
| Hard-coded AMI | Must update per region; use data source in production |

## Cost Awareness
- EC2 t2.micro: **Free** under AWS Free Tier (750 hrs/month)
- Estimated cost if outside Free Tier: ~$8–10/month
- No load balancer, RDS, or NAT Gateway used — minimizes cost

## Setup Instructions
1. `cd terraform && terraform init`
2. `terraform plan -var="key_name=your-key-name"`
3. `terraform apply`
4. Add `EC2_HOST` and `EC2_SSH_KEY` to GitHub Secrets
5. Push to `main` — pipeline auto-deploys

## CI/CD Flow
1. Developer pushes to `main`
2. GitHub Actions triggers
3. Files are SCP'd to EC2
4. NGINX is reloaded
5. App is live at `http://65.1.64.159/`

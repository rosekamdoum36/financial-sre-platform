# Financial SRE Platform

A cloud-native financial transaction processing platform designed to demonstrate Site Reliability 
Engineering practices in a financial-services environment.

## Project Goals

This project demonstrates:

- AWS cloud infrastructure
- Infrastructure as Code with Terraform
- CI/CD automation
- Financial transaction processing
- Monitoring and observability
- Incident detection and response
- Reliability engineering
- Root cause analysis
- Operational automation
- Resiliency and failure recovery

## Initial Architecture

Customer
→ API Gateway
→ Lambda Transaction API
→ SQS
→ Lambda Transaction Worker
→ DynamoDB

## Environments

The project will initially use a development environment located in:

`environments/dev`

Additional environments may be introduced later.

## Project Status

Currently under development.

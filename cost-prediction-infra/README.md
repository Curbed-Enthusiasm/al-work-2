# Introduction 
This repo houses the Terraform that creates the Azure Resources required by the Cost Prediction API.  The API exposes the Cost Prediction Data Science model. See the [Terraform Modules Repo](https://arrivelogistics.visualstudio.com/Accelerate/_git/terraform-modules?path=/function-module) for more info.
### Resources
1.	Azure Function that exposes an HTTP end point
2.	Azure Storage Account to support the Azure Functions
3.	Azure App Service Plan that defines the instance(s) for running the functions
4.  Azure App Insights for monitoring and logging

### Environments
1.	dev
2.	test
3.	stg
4.  prod
# Getting Started
1.	Install Terraform
2.	Install Terragrunt
3.	Navigate to the `terragrunt` folder
    ```
    cd terragrunt
    ```
4.  Set the environment vars below
    ```
    SUBSCRIPTION_ID=2391022b-04f5-42a5-838d-1c0a301df4c8
    CLIENT_ID=***
    CLIENT_SECRET=***
    TENANT_ID=***
    ```
4.	Execute `terragrunt run-all <init, validate, plan, apply>`

Credentials for the Service Principal are stored in the [kv-costprediction-global](https://portal.azure.com/#@ArriveLogistics.onmicrosoft.com/resource/subscriptions/2391022b-04f5-42a5-838d-1c0a301df4c8/resourceGroups/rg-cost-prediction/providers/Microsoft.KeyVault/vaults/kv-costprediction-global/overview)
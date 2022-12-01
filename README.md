# Google Cloud Break Glass Service (Pybreak)

This is small solution to external systems to grant emergency elevated rights (break glass) to Google Cloud projects through a microservice API (written in Python, hence the name Pybreak). The rights are also automatically revoked after 10 hours, and the elevation logged for operations and auditing purposes.

## QuickStart- Cloud Shell setup tutorial

Use the following GCP CloudShell tutorial, and follow the instructions.

[![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.png)](https://ssh.cloud.google.com/cloudshell/open?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/apigee-anthos-service-mesh-demo&cloudshell_git_branch=main&cloudshell_workspace=.&cloudshell_tutorial=docs/cloudshell-tutorial.md)

## Manual deployment

To deploy manually, just make sure you are authorized in gcloud and then follow these steps.

1. Change the project ID to your project in 1_env.sh and call `source 1_env.sh`
2. Run the second script to create the user and role assignments `./2_create_resources.sh`
3. Run the third script `./3_deploy.sh` to deploy the microservice to Cloud Run

Or to just run the service locally:

```ssh
cd src
pip3 install -r requirements.txt

export SERVICE_ACCOUNT=<Your service account email>
export ROLE=<Desired elevated role, by default roles/owner>
export LOCATION=<Your Google Cloud region of choice for the service and task job deployment>
export GCLOUD_PROJECT=<Your Google Cloud project>

python3 server.py
```
# API

The REST API of the service is documented in this [OpenAPI v3 spec](/breakglass-oapi-v1.yaml).

# Configuration

These environment variables are used to configure the service.

| Name | Description |
| ---- | ----------- |
| SERVICE_ACCOUNT | The service account email to be used to configure the Google Cloud Task to revoke the elevated priveleges. |
| ROLE | The role for the user to be elevated to, by default **roles/owner**. |
| LOCATION | The Google Cloud region where the service is running, and where the revoke task job should be executed (for example **us-central1** or **europe-west1**) |
| GCLOUD_PROJECT | The Google Cloud project that the service is running in, and that the revoke task job should be created in. |

## Using and integrating

After deployment, the service can be called by any system that needs to request elevated access for a user and project (see the API docs in [./docs/breakglass-oapi-v1.yaml](./docs/breakglass-oapi-v1.yaml). The authentication is by default [OIDC authentication provided by Cloud Run](https://cloud.google.com/run/docs/authenticating/service-to-service) using the created **breakglassservice** service account. This can be adapted or changed depending on hosting and needed authentication (auth needs to be done outside of the microservice).

## Architecture

This solution is inspired by this solution for [Google Cloud Just-In-Time Access](https://cloud.google.com/architecture/manage-just-in-time-privileged-access-to-project), but simplifies it down to a simple API that can be deployed to Cloud Run or GKE and triggered by an external system, such as a ticket management or identity management system.

Here is an architecture diagram:
![pybreak architecture](./docs/breakglass-arch.png)

The solution is based on a Python microservice that uses the Google Cloud Python SDK to give a user temporary elevated access to a project based on an API call, and then uses [Google Cloud Tasks](https://cloud.google.com/tasks) to configure the revokation of the elevated rights 10 hours later. This way a user gets only elevated rights for a limited amount of time for critical emergencies, and then is automatically removed afterwards.

The microservice also uses [Google Cloud Logging](https://cloud.google.com/logging) to record all operations for future auditing and monitoring purposes.

## Testing

You can use this [Postman collection](/docs/Google_Cloud_Break_Glass.postman_collection.json) to test both local and Cloud Run deployments of the service. 

The requests with **CR** at the end are targeting **Cloud Run**. Change the URL to your Cloud Run deployment URL, and also set your URL in the **Pre-release script** tab on line 29:

```js
// Replace with your Cloud Run URL
const TARGET_AUDIENCE = 'https://breakglassservice-ghfontasua-ew.a.run.app';
```

Then also set a **Postman Environment Variable** called **serviceAccountKey** to a Google Cloud service account JSON key for a service account with the permissions needed (see **2_create_resources.sh** for needed roles).

This Pre-release script retrieves an ID token with your URL as audience, and sends it as Bearer token to Cloud Run, which is needed to authenticate the request.


## Support

This is not an official Google product.
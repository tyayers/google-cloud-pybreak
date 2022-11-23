# Google Cloud Break Glass Service (Pybreak)

This is small solution to external systems to grant emergency elevated rights (break glass) to Google Cloud projects through a microservice API (written in Python, hence the name Pybreak). The rights are also automatically revoked after 10 hours, and the elevation logged for operations and auditing purposes.

## (QuickStart) Demo CloudShell setup tutorial

Use the following GCP CloudShell tutorial, and follow the instructions.

[![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.png)](https://ssh.cloud.google.com/cloudshell/open?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/apigee-anthos-service-mesh-demo&cloudshell_git_branch=main&cloudshell_workspace=.&cloudshell_tutorial=docs/cloudshell-tutorial.md)

## Architecture

This solution is inspired by this solution for [Google Cloud Just-In-Time Access](https://cloud.google.com/architecture/manage-just-in-time-privileged-access-to-project), but simplifies it down to a simple API that can be deployed to Cloud Run or GKE and triggered by an external system, such as a ticket management or identity management system.

Here is an architecture diagram:
![pybreak architecture](./docs/breakglass-arch.png)

The solution is based on a Python microservice that uses the Google Cloud Python SDK to give a user temporary elevated access to a project based on an API call, and then uses [Google Cloud Tasks](https://cloud.google.com/tasks) to configure the revokation of the elevated rights 10 hours later. This way a user gets only elevated rights for a limited amount of time for critical emergencies, and then is automatically removed afterwards.

The microservice also uses [Google Cloud Logging](https://cloud.google.com/logging) to record all operations for future auditing and monitoring purposes.
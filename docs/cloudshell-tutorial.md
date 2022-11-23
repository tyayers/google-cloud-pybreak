# Google Cloud Break Glass Microservice Tutorial

---
This tutorial shows how to deploy a simple Python microservice in Google Cloud to manage [break glass](https://www.beyondtrust.com/blog/entry/provide-security-privileged-accounts-with-break-glass-process) access rights elevation for accounts in case of a critical emergency.

Let's get started!

---

## Setup environment

Edit the provided sample `1_env.sh` file, and set the environment variables there.

Click <walkthrough-editor-open-file filePath="1_env.sh">here</walkthrough-editor-open-file> to open the file in the editor

Then, source the `env.sh` file in the Cloud shell.

```sh
source ./env.sh
```

---

## Enable GCP APIs and create resources

Now we can enable all needed GCP APIs, and create the service account and strict role access needed to perform the break glass operation.

```sh
./2_create_resources.sh
```

<walkthrough-footnote>The new service account will be called *breakglassservice*, and have just the rights needed to assign a user an elevated role in case of a crticial emergency.</walkthrough-footnote>

---

## Deploy microservice

Next, let's deploy our python microservice to the Google Cloud Run serverless platform, for easy access from any workflow or client apps managing emergency access via a REST API.

```sh
./3_deploy.sh
```

This deployment will result in a public endpoint that is secured with Google IAM access so that only an authorized service account can call the method.

### Test the break glass functionality

Now let's do a test call to give elevated rights to a user.

---
## Conclusion

<walkthrough-conclusion-trophy></walkthrough-conclusion-trophy>

Congratulations! You've successfully deployed the break glass service, and tested giving elevated access to a user, and then revoking that access.

<walkthrough-inline-feedback></walkthrough-inline-feedback>

##### Cleanup

To cleanup, simply call this script.

##### What's next?

Learn more about the [Cloud Shell](https://cloud.google.com/shell) IDE environment and the [Cloud Code](https://cloud.google.com/code) extension.
# Copyright 2022 Google LLC

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     https://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Enable APIs
gcloud services enable cloudbuild.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable compute.googleapis.com
gcloud services enable orgpolicy.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable logging.googleapis.com
gcloud services enable cloudtasks.googleapis.com

# Create a service account user to run breakglass service
gcloud iam service-accounts create breakglassservice \
    --description="Service account to manage breakglass requests" \
    --display-name="BreakGlassService"

## Now give the service account the rights to perform needed operations
gcloud projects add-iam-policy-binding $PROJECT \
    --member="serviceAccount:breakglassservice@$PROJECT.iam.gserviceaccount.com" \
    --role="roles/resourcemanager.projectIamAdmin"

gcloud projects add-iam-policy-binding $PROJECT \
    --member="serviceAccount:breakglassservice@$PROJECT.iam.gserviceaccount.com" \
    --role="roles/run.admin"

gcloud projects add-iam-policy-binding $PROJECT \
    --member="serviceAccount:breakglassservice@$PROJECT.iam.gserviceaccount.com" \
    --role="roles/iam.serviceAccountUser"

gcloud projects add-iam-policy-binding $PROJECT \
    --member="serviceAccount:breakglassservice@$PROJECT.iam.gserviceaccount.com" \
    --role="roles/logging.logWriter"

gcloud projects add-iam-policy-binding $PROJECT \
    --member="serviceAccount:breakglassservice@$PROJECT.iam.gserviceaccount.com" \
    --role="roles/cloudtasks.enqueuer"

gcloud projects add-iam-policy-binding $PROJECT \
    --member="serviceAccount:breakglassservice@$PROJECT.iam.gserviceaccount.com" \
    --role="roles/cloudtasks.taskDeleter"

gcloud projects add-iam-policy-binding $PROJECT \
    --member="serviceAccount:breakglassservice@$PROJECT.iam.gserviceaccount.com" \
    --role="roles/cloudtasks.viewer"

# Create the tasks queue to reset permissions
gcloud tasks queues create breakglass-reset-queue --location $LOCATION
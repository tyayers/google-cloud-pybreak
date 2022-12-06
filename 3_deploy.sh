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

export PROJECT=$(gcloud config get-value project)

# Build container image
gcloud builds submit --tag "eu.gcr.io/$PROJECT/breakglassservice"

# Deploy image to Cloud Run with the correct service account
gcloud run deploy breakglassservice --image eu.gcr.io/$PROJECT/breakglassservice \
    --platform managed --project $PROJECT \
    --region $LOCATION --no-allow-unauthenticated \
    --service-account="breakglassservice@$PROJECT.iam.gserviceaccount.com" \
    --set-env-vars SERVICE_ACCOUNT="breakglassservice@$PROJECT.iam.gserviceaccount.com",LOCATION="$LOCATION",GCLOUD_PROJECT="$PROJECT"

    
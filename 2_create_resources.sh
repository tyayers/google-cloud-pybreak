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
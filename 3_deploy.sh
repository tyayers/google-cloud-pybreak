export PROJECT=$(gcloud config get-value project)

# Build container image
gcloud builds submit --tag "eu.gcr.io/$PROJECT/breakglassservice"

# Deploy image to Cloud Run with the correct service account
gcloud run deploy breakglassservice --image eu.gcr.io/$PROJECT/breakglassservice \
    --platform managed --project $PROJECT \
    --region $LOCATION --no-allow-unauthenticated \
    --service-account="breakglassservice@$PROJECT.iam.gserviceaccount.com" \
    --set-env-vars SERVICE_ACCOUNT="breakglassservice@$PROJECT.iam.gserviceaccount.com",LOCATION="$LOCATION"

    
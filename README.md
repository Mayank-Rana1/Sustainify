# Sustainify AI

A focused product-lifecycle sustainability assistant with two workflows:

- **Shop Smart:** estimates the environmental quality of visible packaging before purchase.
- **Dispose Smart:** recommends reuse, repair, donation, recycling, composting, or safe disposal after use.

## Run locally

The frontend has no build dependency:

```bash
cd frontend
python3 -m http.server 8080
```

Open `http://localhost:8080`.

## Current MVP

- Responsive home and two-mode scanner
- Camera/gallery image capture
- Product Eco Score with transparent breakdown
- Packaging and recyclability explanation
- Better product-type recommendation
- Post-use action guidance and safety warning
- Safe DIY suggestion when applicable
- Local scan history, feedback, and completion tracking
- Honest impact dashboard
- AWS SAM backend starter for S3, Lambda, API Gateway, DynamoDB, and Bedrock permissions

The browser demo intentionally uses local deterministic rules so it can run without API credentials. Replace `shopResult()` and `disposeResult()` with calls to the deployed API for production.

## AWS deployment

```bash
cd backend
sam build
sam deploy --guided
```

Host `frontend/` with AWS Amplify Hosting or S3 and CloudFront. Configure the frontend API base URL after deployment.

## Reuse declaration

This consolidated implementation was created as a separate project. If UI, code, prompts, or assets from the earlier Sustain-ify repository are copied into this project, identify them in `ATTRIBUTIONS.md` and in the hackathon submission. Permission to reuse does not remove event disclosure requirements.

## Responsible AI

- Eco Scores are estimates, not official certifications.
- Recycling acceptance varies by municipality.
- Environmental claims visible on labels are not independently verified.
- Hazardous, chemical, medical, battery, and sharp items require official local guidance.
- Low-confidence analysis should return manual review rather than certainty.

## Suggested production Bedrock response

Return strict JSON with `analysisType`, identified materials, confidence, visible claims, and controlled actions. Calculate the final Eco Score in Lambda using transparent rules rather than accepting a model-generated score.

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

Open `http://localhost:8080`

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
🌍 The Problem That Made Me Build This
Here's a number that changed how I think about consumption: over 2 billion tonnes of waste ends up in landfills every single year. That's not a distant, abstract statistic — it's the plastic container I threw away last Tuesday because I didn't know it was recyclable.

The truth is, most of us want to make sustainable choices. But the information is buried in fine print, scattered across obscure websites, or simply doesn't exist for the product sitting in our hands.

I kept asking myself one question:

What if your phone camera could instantly tell you — before you buy — whether a product is eco-friendly? And after you're done with it — exactly how to dispose of it responsibly?

That question became Sustainify AI.

🔧 What is Sustainify AI?
Sustainify AI is a mobile application built with Flutter that helps users make sustainable decisions at two critical moments in a product's lifecycle:

🛒 Shop Smart — Before You Buy
Point your camera at any product or its packaging. In under 3 seconds, you get:

An instant eco-score (0–100) across 5 weighted dimensions
Recyclability analysis — can it be recycled in standard programs?
Material breakdown — what's it actually made of?
Better alternatives — suggestions for more sustainable options
♻️ Dispose Smart — After You're Done
Scan an item you want to get rid of. The app tells you:

The best action: Recycle, Donate, Compost, Repair, Reuse, or Safe Disposal
Step-by-step instructions specific to the detected material
Hazard flags for batteries, electronics, or chemicals
DIY upcycling ideas — because the most sustainable product is the one you don't throw away
🏗️ Architecture: 100% AWS, Zero External Dependencies
Every byte of compute, storage, and intelligence runs on AWS Free Tier. No external AI APIs. No third-party services. No surprise invoices.

AWS Service	Role	Free Tier Allowance
Amazon API Gateway	HTTP entry point — routes all client requests	1M requests/month
AWS Lambda	Serverless compute — runs the analysis engine	1M invocations/month
Amazon S3	Secure image storage with presigned upload URLs	5 GB storage
Amazon DynamoDB	NoSQL database — stores every scan per user	25 GB + 25 RCU/WCU
Amazon Rekognition	Computer vision — detects materials, objects, packaging	5,000 images/month
Amazon Cognito	User authentication with email verification	50,000 MAU

 ┌─────────────┐     ┌──────────────┐     ┌──────────┐
│  Flutter App │────▶│ API Gateway  │────▶│  Lambda  │
│  (Mobile)    │     │  (REST API)  │     │ (Engine) │
└─────────────┘     └──────────────┘     └──────┬───┘
       │                                        │
       │ JWT Token                    ┌─────────┼─────────┐
       │                              │         │         │
  ┌────▼─────┐                  ┌─────▼──┐ ┌────▼───┐ ┌───▼────────┐
  │ Cognito  │                  │   S3   │ │Rekogn. │ │ DynamoDB   │
  │ (Auth)   │                  │(Images)│ │ (AI)   │ │ (History)  │
  └──────────┘                  └────────┘ └────────┘ └────────────┘

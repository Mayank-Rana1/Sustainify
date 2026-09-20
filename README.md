# 🌿 Sustainify AI

<div align="center">

**Scan any product. Get instant sustainability intelligence.**

*AI-powered eco-scoring and disposal guidance — 100% serverless on AWS Free Tier*

[![AWS SAM](https://img.shields.io/badge/AWS_SAM-Serverless-FF9900?logo=amazonaws&logoColor=white)](https://aws.amazon.com/serverless/sam/)
[![Flutter](https://img.shields.io/badge/Flutter-Mobile_App-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
[![Amazon Rekognition](https://img.shields.io/badge/Amazon_Rekognition-Computer_Vision-FF9900?logo=amazonaws)](https://aws.amazon.com/rekognition/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Python](https://img.shields.io/badge/Python-3.9+-3776AB?logo=python&logoColor=white)](https://python.org)

---

[Features](#-features) · [Architecture](#-architecture) · [Tech Stack](#-tech-stack) · [Getting Started](#-getting-started) · [API Reference](#-api-reference) · [How It Works](#-how-it-works) · [Project Structure](#-project-structure)

</div>

---

## 🌍 The Problem

> **Over 2 billion tonnes of waste** ends up in landfills every year. Most consumers have no idea whether the product they're buying is recyclable, what materials it contains, or how to properly dispose of it.

Sustainify AI puts sustainability intelligence directly in your hands — just point your camera.

---

## ✨ Features

### 🛒 Shop Smart — Before You Buy
Scan any product or packaging before purchase to get:
- **Eco-Score** (0–100) across 5 weighted dimensions
- **Material breakdown** — what it's actually made of
- **Recyclability analysis** — can it be recycled in standard programs?
- **Packaging assessment** — environmental impact of packaging
- **Better alternatives** — suggestions for eco-friendlier options

### ♻️ Dispose Smart — After You're Done
Scan any item you want to get rid of:
- **Best action**: Recycle, Donate, Compost, Repair, Reuse, or Safe Disposal
- **Step-by-step instructions** specific to detected material
- **Hazard flags** for batteries, electronics, chemicals
- **DIY upcycling ideas** — because the best waste is waste that never reaches a landfill

### 📊 Additional Features
- 🔐 Secure auth with email verification (Amazon Cognito)
- 📸 Camera and gallery image capture
- 📜 Persistent scan history — your personal sustainability journal
- 📈 Impact dashboard with honest metrics
- 🌙 Dark mode support
- 📱 Fully responsive mobile UI

---

## 🏗️ Architecture

### System Overview

```
User opens app
    │
    ▼
┌──────────────────┐
│  Amazon Cognito   │  ── Sign up / Login ── JWT Token
└────────┬─────────┘
         │
         ▼
┌──────────────────┐        ┌─────────────────┐
│   Flutter App     │───────▶│  API Gateway     │
│   (Mobile)        │        │  (REST API)      │
└──────────────────┘        └────────┬────────┘
                                     │
                                     ▼
                            ┌─────────────────┐
                            │  AWS Lambda      │
                            │  (Python 3.9)    │
                            └──┬─────┬──────┬─┘
                               │     │      │
                    ┌──────────┘     │      └──────────┐
                    ▼                ▼                  ▼
            ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
            │  Amazon S3    │ │  Amazon       │ │  Amazon      │
            │  (Images)     │ │  Rekognition  │ │  DynamoDB    │
            │               │ │  (Vision AI)  │ │  (History)   │
            └──────────────┘ └──────────────┘ └──────────────┘
```

### AWS Services Used

| Service | Role | Free Tier |
|---------|------|-----------|
| **Amazon API Gateway** | HTTP entry point — routes all requests | 1M requests/month |
| **AWS Lambda** | Serverless compute — sustainability engine | 1M invocations/month |
| **Amazon S3** | Secure image storage with presigned URLs | 5 GB storage |
| **Amazon DynamoDB** | NoSQL database — stores scans per user | 25 GB + 25 RCU/WCU |
| **Amazon Rekognition** | Computer vision — detects materials & objects | 5,000 images/month |
| **Amazon Cognito** | User authentication with email verification | 50,000 MAU |

> **Zero external APIs. Zero third-party services. Zero monthly bills.** Everything runs on AWS Free Tier.

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|------------|
| **Frontend** | Flutter (Dart) — cross-platform mobile |
| **Backend** | Python 3.9 on AWS Lambda |
| **AI/ML** | Amazon Rekognition (`DetectLabels`) |
| **Auth** | Amazon Cognito (JWT + SRP) |
| **Storage** | Amazon S3 (presigned URLs) |
| **Database** | Amazon DynamoDB (single-table design) |
| **API** | Amazon API Gateway (HTTP API) |
| **IaC** | AWS SAM (Infrastructure as Code) |

---

## 🚀 Getting Started

### Prerequisites

- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) configured with credentials
- [AWS SAM CLI](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/install-sam-cli.html)
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.0+)
- Python 3.9+

### 1. Deploy the Backend

```bash
cd backend
sam build
sam deploy --guided
```

SAM will create all 6 AWS resources and output:
- ✅ API Gateway endpoint URL
- ✅ Cognito User Pool ID
- ✅ Cognito Client ID
- ✅ S3 Bucket name

### 2. Configure the Flutter App

Update `frontend/lib/api_service.dart` with the SAM outputs:

```dart
static const String baseUrl = 'YOUR_API_GATEWAY_URL';
static const String userPoolId = 'YOUR_COGNITO_USER_POOL_ID';
static const String clientId = 'YOUR_COGNITO_CLIENT_ID';
```

### 3. Run the App

```bash
cd frontend
flutter pub get
flutter run
```

### 4. Local Demo (No AWS Required)

The frontend includes local deterministic rules for demo purposes:

```bash
cd frontend
python3 -m http.server 8080
# Open http://localhost:8080
```

---

## 📡 API Reference

All endpoints are served through API Gateway and protected by Cognito JWT auth.

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/health` | Health check — lists active AWS services |
| `POST` | `/upload-url` | Generate presigned S3 URL for direct image upload |
| `POST` | `/analyze-direct` | Analyze image (base64 in body — no S3 CORS needed) |
| `POST` | `/analyses` | Analyze image already in S3 (presigned URL flow) |
| `GET` | `/analyses` | Retrieve user's scan history from DynamoDB |

### Example: Analyze an Image

```bash
curl -X POST https://YOUR_API_URL/analyze-direct \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "mode": "shop",
    "image": "BASE64_ENCODED_IMAGE",
    "name": "Water Bottle"
  }'
```

### Example Response (Shop Smart)

```json
{
  "type": "shop",
  "name": "Water Bottle",
  "ecoScore": 72,
  "packaging": { "score": 18, "max": 25, "note": "Recyclable packaging" },
  "material": { "score": 20, "max": 25, "note": "Glass — highly recyclable" },
  "recyclability": { "score": 16, "max": 20 },
  "reusability": { "score": 10, "max": 15 },
  "productSignals": { "score": 8, "max": 15 },
  "detected_labels": [
    { "name": "Bottle", "confidence": 97.2 },
    { "name": "Glass", "confidence": 94.8 }
  ]
}
```

---

## 🧠 How It Works

### Step 1: Authentication
User signs up with email → Cognito sends verification email → JWT token issued on login → token attached to all API calls.

### Step 2: Image Upload
App calls Lambda → Lambda generates **presigned S3 URL** → Flutter uploads image **directly to S3** (bypasses API Gateway payload limits and data transfer costs).

### Step 3: AI Analysis
Lambda calls **Amazon Rekognition `DetectLabels`** → returns up to 20 labeled objects with confidence scores → Lambda maps labels through the **Sustainability Knowledge Base** (20+ material categories).

### Step 4: Scoring Engine

**Shop Smart** — 5-dimensional scoring (100 points total):

| Dimension | Weight | Measures |
|-----------|--------|----------|
| Packaging | 25 pts | Environmental impact of packaging |
| Material | 25 pts | Eco-friendliness of materials |
| Recyclability | 20 pts | Standard recycling compatibility |
| Reusability | 15 pts | Repurposing potential |
| Product Signals | 15 pts | Eco-positive indicators |

**Dispose Smart** — determines the single best action:
- ♻️ **RECYCLE** — material-specific sorting instructions
- 🎁 **DONATE** — local donation suggestions
- 🌱 **COMPOST** — composting method & tips
- 🔧 **REPAIR** — feasibility assessment
- 🔄 **REUSE** — creative DIY upcycling ideas
- ⚠️ **SAFE DISPOSAL** — hazardous material handling

### Step 5: History
Every scan is stored in DynamoDB (`PK: USER#{userId}`, `SK: ANALYSIS#{timestamp}#{id}`) — building a personal sustainability journal.

---

## 📂 Project Structure

```
Sustainify/
├── backend/
│   ├── template.yaml          # AWS SAM template — defines all 6 AWS resources
│   └── src/
│       └── app.py             # Lambda function — API routes + scoring engine
│                              #   └── MATERIAL_SCORES knowledge base (20 categories)
│                              #   └── _analyze_shop()  — Shop Smart scoring
│                              #   └── _analyze_dispose() — Dispose Smart guidance
│                              #   └── handler() — API Gateway event router
│
├── frontend/
│   ├── lib/
│   │   ├── main.dart          # App entry point + home screen
│   │   ├── main_navigation.dart  # Bottom nav + routing
│   │   ├── login_page.dart    # Cognito login
│   │   ├── signup_page.dart   # Cognito signup + email verification
│   │   ├── scanning_page.dart # Camera/gallery capture + mode selection
│   │   ├── profile_page.dart  # User profile + scan history
│   │   ├── api_service.dart   # AWS API client (Cognito auth + API calls)
│   │   └── widgets.dart       # Reusable UI components + result displays
│   ├── assets/images/         # App images (login, signup, profile)
│   ├── android/               # Android platform config
│   ├── ios/                   # iOS platform config
│   └── pubspec.yaml           # Flutter dependencies
│
├── ATTRIBUTIONS.md            # Reuse and attribution declarations
└── README.md                  # You are here
```

---

## 🤔 Why Rekognition over Bedrock?

| Factor | Rekognition | Bedrock |
|--------|-------------|---------|
| **Activation** | Instant — no access request | Requires approval (days) |
| **Free Tier** | 5,000 images/month | Limited / varies |
| **Latency** | Structured labels in <2s | Token generation, higher |
| **Output** | Deterministic JSON | Probabilistic / varies |
| **Fit** | Purpose-built for object detection | General-purpose |

> **Key insight:** Not every AI problem needs a foundation model. Rekognition + curated domain logic = fast, reliable, and free.

---

## ⚠️ Responsible AI

- Eco-Scores are **estimates**, not official certifications
- Recycling acceptance **varies by municipality**
- Environmental claims on labels are not independently verified
- Hazardous, chemical, medical, battery, and sharp items require **official local guidance**
- Low-confidence analysis returns a manual review recommendation

---

## 🗺️ Roadmap

- [ ] 📊 Barcode/QR scanning for richer product data
- [ ] 🏆 Community leaderboards (DynamoDB Streams + Lambda)
- [ ] 📍 Region-specific disposal rules
- [ ] 🌿 Lifetime carbon footprint tracking per user
- [ ] 🔔 Push notifications for eco-tips
- [ ] 🌐 Multi-language support

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

---

<div align="center">

**Built with ❤️ for the planet, powered entirely by AWS**

*Sustainify AI — Because every scan is a step toward sustainability* 🌱

</div>

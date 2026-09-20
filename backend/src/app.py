import json, os, time, uuid, base64
import boto3
from botocore.exceptions import ClientError

s3 = boto3.client('s3')
ddb = boto3.resource('dynamodb').Table(os.environ['TABLE_NAME'])
rekognition = boto3.client('rekognition')
BUCKET = os.environ['BUCKET_NAME']

# ---------- Material sustainability knowledge base ----------
MATERIAL_SCORES = {
    'plastic': {'recyclability': 8, 'eco': 20, 'action': 'RECYCLE', 'hazard': False,
                'category': 'Household material', 'material': 'Plastic'},
    'bottle': {'recyclability': 14, 'eco': 40, 'action': 'RECYCLE', 'hazard': False,
               'category': 'Household material', 'material': 'Plastic/Glass'},
    'glass': {'recyclability': 18, 'eco': 60, 'action': 'RECYCLE', 'hazard': False,
              'category': 'Household material', 'material': 'Glass'},
    'metal': {'recyclability': 16, 'eco': 55, 'action': 'RECYCLE', 'hazard': False,
              'category': 'Household material', 'material': 'Metal'},
    'aluminum': {'recyclability': 18, 'eco': 65, 'action': 'RECYCLE', 'hazard': False,
                 'category': 'Household material', 'material': 'Aluminum'},
    'paper': {'recyclability': 16, 'eco': 70, 'action': 'RECYCLE', 'hazard': False,
              'category': 'Household material', 'material': 'Paper'},
    'cardboard': {'recyclability': 18, 'eco': 75, 'action': 'RECYCLE', 'hazard': False,
                  'category': 'Household material', 'material': 'Cardboard'},
    'wood': {'recyclability': 12, 'eco': 70, 'action': 'REUSE', 'hazard': False,
             'category': 'Household material', 'material': 'Wood'},
    'textile': {'recyclability': 8, 'eco': 45, 'action': 'DONATE', 'hazard': False,
                'category': 'Household material', 'material': 'Textile/Fabric'},
    'clothing': {'recyclability': 8, 'eco': 45, 'action': 'DONATE', 'hazard': False,
                 'category': 'Household material', 'material': 'Textile/Fabric'},
    'electronics': {'recyclability': 6, 'eco': 20, 'action': 'SAFE DISPOSAL', 'hazard': True,
                    'category': 'E-waste', 'material': 'Mixed electronics'},
    'battery': {'recyclability': 4, 'eco': 10, 'action': 'SAFE DISPOSAL', 'hazard': True,
                'category': 'Hazardous household waste', 'material': 'Lithium/Alkaline'},
    'food': {'recyclability': 0, 'eco': 60, 'action': 'COMPOST', 'hazard': False,
             'category': 'Organic waste', 'material': 'Organic matter'},
    'fruit': {'recyclability': 0, 'eco': 80, 'action': 'COMPOST', 'hazard': False,
              'category': 'Organic waste', 'material': 'Organic matter'},
    'vegetable': {'recyclability': 0, 'eco': 80, 'action': 'COMPOST', 'hazard': False,
                  'category': 'Organic waste', 'material': 'Organic matter'},
    'ceramic': {'recyclability': 4, 'eco': 40, 'action': 'REUSE', 'hazard': False,
                'category': 'Household material', 'material': 'Ceramic'},
    'rubber': {'recyclability': 6, 'eco': 30, 'action': 'SAFE DISPOSAL', 'hazard': False,
               'category': 'Household material', 'material': 'Rubber'},
    'furniture': {'recyclability': 10, 'eco': 50, 'action': 'DONATE', 'hazard': False,
                  'category': 'Household material', 'material': 'Mixed (Wood/Metal/Fabric)'},
    'toy': {'recyclability': 8, 'eco': 40, 'action': 'DONATE', 'hazard': False,
            'category': 'Household material', 'material': 'Plastic/Mixed'},
    'container': {'recyclability': 14, 'eco': 50, 'action': 'REUSE', 'hazard': False,
                  'category': 'Household material', 'material': 'Plastic/Glass'},
    'bag': {'recyclability': 6, 'eco': 25, 'action': 'REUSE', 'hazard': False,
            'category': 'Household material', 'material': 'Plastic/Fabric'},
    'can': {'recyclability': 18, 'eco': 65, 'action': 'RECYCLE', 'hazard': False,
            'category': 'Household material', 'material': 'Aluminum/Steel'},
}

PACKAGING_KEYWORDS = {'plastic', 'wrapper', 'packaging', 'box', 'cardboard', 'bag', 'container', 'bottle', 'can', 'jar'}
ECO_POSITIVE_KEYWORDS = {'paper', 'cardboard', 'glass', 'wood', 'bamboo', 'cotton', 'natural', 'organic', 'plant', 'leaf'}
ECO_NEGATIVE_KEYWORDS = {'plastic', 'styrofoam', 'polystyrene', 'synthetic', 'chemical'}

def resp(code, body):
    return {
        'statusCode': code,
        'headers': {'content-type': 'application/json', 'access-control-allow-origin': '*',
                    'access-control-allow-methods': 'GET,POST,PUT,DELETE,OPTIONS',
                    'access-control-allow-headers': 'Content-Type,Authorization'},
        'body': json.dumps(body, default=str)
    }

def _match_labels(labels):
    """Match Rekognition labels against our material knowledge base."""
    matched = []
    label_names = [l['Name'].lower() for l in labels]
    for name in label_names:
        for keyword, data in MATERIAL_SCORES.items():
            if keyword in name:
                matched.append({'label': name, 'confidence': next(
                    l['Confidence'] for l in labels if l['Name'].lower() == name
                ), **data})
                break
    return matched, label_names

def _analyze_shop(labels, name, details):
    """Build Shop Smart analysis from Rekognition labels."""
    matched, label_names = _match_labels(labels)
    
    # Packaging analysis
    packaging_labels = [l for l in label_names if l in PACKAGING_KEYWORDS]
    packaging_desc = f"Detected packaging: {', '.join(packaging_labels)}" if packaging_labels else "No specific packaging detected in image"
    
    # Eco scoring
    positives = [l for l in label_names if l in ECO_POSITIVE_KEYWORDS]
    concerns = [l for l in label_names if l in ECO_NEGATIVE_KEYWORDS]
    
    # Calculate scores
    base_score = 50
    base_score += len(positives) * 8
    base_score -= len(concerns) * 10
    if matched:
        avg_recyclability = sum(m['recyclability'] for m in matched) / len(matched)
        base_score = int(base_score * 0.6 + avg_recyclability / 20 * 100 * 0.4)
    score = max(5, min(95, base_score))
    
    if score >= 80: rating = "Excellent"
    elif score >= 60: rating = "Good"
    elif score >= 40: rating = "Average"
    elif score >= 20: rating = "Poor"
    else: rating = "Very Poor"
    
    # Breakdown
    pkg_score = min(25, 15 + len(positives) * 3 - len(concerns) * 4)
    mat_score = min(25, int(score * 0.25))
    rec_score = min(20, int(sum(m.get('recyclability', 10) for m in matched) / max(1, len(matched))))
    reu_score = min(15, 8 + len([m for m in matched if m.get('action') == 'REUSE']) * 4)
    sig_score = min(15, score // 7)
    
    return {
        "type": "shop",
        "name": name or "Product",
        "score": score,
        "rating": rating,
        "confidence": round(sum(l['Confidence'] for l in labels[:5]) / max(1, min(5, len(labels))) / 100, 2),
        "packaging": packaging_desc,
        "recyclability": f"Recyclability score: {rec_score}/20. " + (
            f"Materials detected: {', '.join(m['material'] for m in matched[:3])}" if matched else "Unable to determine specific materials"
        ),
        "positives": [f"Contains {p} (eco-friendly material)" for p in positives] or ["Product detected successfully"],
        "concerns": [f"Contains {c} (environmental concern)" for c in concerns] or ["No major concerns detected"],
        "breakdown": {
            "Packaging": max(0, pkg_score),
            "Material": max(0, mat_score),
            "Recyclability": max(0, rec_score),
            "Reusability": max(0, reu_score),
            "Product signals": max(0, sig_score)
        },
        "better": "Consider products with minimal packaging and recyclable materials.",
        "detected_labels": [{"name": l['Name'], "confidence": round(l['Confidence'], 1)} for l in labels[:10]]
    }

def _analyze_dispose(labels, name, condition, details):
    """Build Dispose Smart analysis from Rekognition labels."""
    matched, label_names = _match_labels(labels)
    
    if matched:
        best = max(matched, key=lambda m: m['confidence'])
        action = best['action']
        material = best['material']
        category = best['category']
        hazard = best['hazard']
    else:
        action = "SAFE DISPOSAL"
        material = "Unknown material"
        category = "General waste"
        hazard = False
    
    # Adjust based on condition
    if condition and 'broken' in condition.lower():
        if action == 'DONATE': action = 'REPAIR'
    if condition and 'good' in condition.lower():
        if action in ('SAFE DISPOSAL', 'RECYCLE'): action = 'DONATE'
    
    steps_map = {
        'RECYCLE': [f"Clean the {name or 'item'} thoroughly", "Check local recycling guidelines for accepted materials",
                    "Place in the appropriate recycling bin", "Remove any non-recyclable components first"],
        'DONATE': [f"Clean and prepare the {name or 'item'}", "Check if local charities accept this type of item",
                   "Package securely for transport", "Drop off at donation center or schedule pickup"],
        'COMPOST': [f"Break down the {name or 'item'} into smaller pieces", "Add to your compost bin or garden",
                    "Mix with brown materials (leaves, cardboard)", "Keep compost moist and aerated"],
        'SAFE DISPOSAL': [f"Check local hazardous waste guidelines", "Do NOT place in regular trash or recycling",
                          "Find nearest designated drop-off facility", "Transport safely in sealed container"],
        'REPAIR': [f"Assess the damage to the {name or 'item'}", "Search for local repair shops or online guides",
                   "Gather necessary repair materials", "Consider professional repair if complex"],
        'REUSE': [f"Clean the {name or 'item'} thoroughly", "Consider creative repurposing ideas",
                  "Use as storage, planter, organizer, or craft material", "Share reuse ideas on community forums"],
    }
    
    diy_map = {
        'plastic': f"Cut and reshape into a small planter or organizer",
        'bottle': f"Transform into a self-watering planter or bird feeder",
        'glass': f"Use as a decorative vase, candle holder, or storage jar",
        'cardboard': f"Create storage boxes, drawer dividers, or kids' craft projects",
        'textile': f"Make cleaning rags, tote bags, or patchwork quilts",
        'wood': f"Build a small shelf, picture frame, or garden marker",
        'can': f"Create a pencil holder, herb planter, or lantern",
        'container': f"Reuse as lunch box, craft supply organizer, or seed starter",
    }
    
    diy = None
    for key in diy_map:
        if any(key in ln for ln in label_names):
            diy = diy_map[key]
            break
    
    return {
        "type": "dispose",
        "name": name or "Item",
        "action": action,
        "confidence": round(sum(l['Confidence'] for l in labels[:5]) / max(1, min(5, len(labels))) / 100, 2),
        "material": material,
        "category": category,
        "hazard": hazard,
        "steps": steps_map.get(action, ["Consult local waste management guidelines"]),
        "diy": diy,
        "detected_labels": [{"name": l['Name'], "confidence": round(l['Confidence'], 1)} for l in labels[:10]]
    }


def handler(event, context):
    method = event.get('requestContext', {}).get('http', {}).get('method', 'GET')
    path = event.get('rawPath', '/')
    user = event.get('requestContext', {}).get('authorizer', {}).get('jwt', {}).get('claims', {}).get('sub', 'guest')

    # Handle CORS preflight
    if method == 'OPTIONS':
        return resp(200, {})

    # ---- 1. Health check ----
    if method == 'GET' and path == '/health':
        return resp(200, {'status': 'ok', 'services': ['S3', 'DynamoDB', 'Rekognition', 'Lambda', 'API Gateway']})

    # ---- 2. Generate Presigned URL for S3 Upload ----
    if method == 'POST' and path == '/upload-url':
        body = json.loads(event.get('body') or '{}')
        ext = body.get('extension', 'jpg').lower()
        if ext not in ('jpg', 'jpeg', 'png', 'webp'):
            return resp(400, {'error': 'Unsupported image type. Use jpg, jpeg, png, or webp'})
        key = f"uploads/{user}/{uuid.uuid4()}.{ext}"
        url = s3.generate_presigned_url(
            'put_object',
            Params={'Bucket': BUCKET, 'Key': key, 'ContentType': f'image/{ext}'},
            ExpiresIn=300
        )
        return resp(200, {'uploadUrl': url, 'imageKey': key})

    # ---- 3. Direct analyze (base64 image in body — no S3 CORS needed) ----
    if method == 'POST' and path == '/analyze-direct':
        try:
            body = json.loads(event.get('body') or '{}')
            mode = body.get('mode', 'shop')
            image_b64 = body.get('image')
            name = body.get('name', '')
            details = body.get('details', '')
            condition = body.get('condition', '')

            if not image_b64:
                return resp(400, {'error': 'image (base64) is required'})

            try:
                image_bytes = base64.b64decode(image_b64)
            except Exception as b64_err:
                return resp(400, {'error': f'Invalid base64 image data: {str(b64_err)}'})

            # Upload to S3 server-side (no CORS issues)
            ext = 'jpg'
            image_key = f"uploads/{user}/{uuid.uuid4()}.{ext}"
            try:
                s3.put_object(Bucket=BUCKET, Key=image_key, Body=image_bytes, ContentType=f'image/{ext}')
            except Exception as e:
                print(f"S3 upload error: {e}")
                # Don't fail if S3 put fails, still run Rekognition

            # Call Amazon Rekognition
            try:
                rek_response = rekognition.detect_labels(
                    Image={'Bytes': image_bytes},
                    MaxLabels=20,
                    MinConfidence=60
                )
                labels = rek_response.get('Labels', [])
            except Exception as e:
                print(f"Rekognition error: {e}")
                labels = []

            # Build sustainability analysis
            if mode == 'shop':
                ai_result = _analyze_shop(labels, name, details)
            else:
                ai_result = _analyze_dispose(labels, name, condition, details)

            # Save to DynamoDB
            aid = str(uuid.uuid4())
            now = int(time.time())
            item = {
                'PK': f'USER#{user}',
                'SK': f'ANALYSIS#{now}#{aid}',
                'analysisId': aid,
                'createdAt': now,
                'mode': mode,
                'name': name,
                'details': details,
                'condition': condition,
                'imageKey': image_key,
                'result': ai_result
            }
            try:
                ddb.put_item(Item=item)
            except Exception as e:
                print(f"DynamoDB error: {e}")

            return resp(200, item)
        except Exception as general_err:
            import traceback
            trace = traceback.format_exc()
            print(f"General error in analyze-direct: {trace}")
            return resp(500, {'error': str(general_err), 'trace': trace})

    # ---- 4. Analyze image using Amazon Rekognition (S3 presigned flow) ----
    if method == 'POST' and path.startswith('/analyses'):
        body = json.loads(event.get('body') or '{}')
        mode = body.get('mode', 'shop')
        image_key = body.get('imageKey')
        name = body.get('name', '')
        details = body.get('details', '')
        condition = body.get('condition', '')

        if not image_key:
            return resp(400, {'error': 'imageKey is required'})

        # Call Amazon Rekognition to detect labels in the image
        try:
            rek_response = rekognition.detect_labels(
                Image={'S3Object': {'Bucket': BUCKET, 'Name': image_key}},
                MaxLabels=20,
                MinConfidence=60
            )
            labels = rek_response.get('Labels', [])
        except ClientError as e:
            return resp(500, {'error': f'Amazon Rekognition failed: {str(e)}'})

        # Build sustainability analysis from Rekognition labels
        if mode == 'shop':
            ai_result = _analyze_shop(labels, name, details)
        else:
            ai_result = _analyze_dispose(labels, name, condition, details)

        # Save analysis to DynamoDB
        aid = str(uuid.uuid4())
        now = int(time.time())
        item = {
            'PK': f'USER#{user}',
            'SK': f'ANALYSIS#{now}#{aid}',
            'analysisId': aid,
            'createdAt': now,
            'mode': mode,
            'name': name,
            'details': details,
            'condition': condition,
            'imageKey': image_key,
            'result': ai_result
        }
        ddb.put_item(Item=item)
        return resp(201, item)

    # ---- 5. Retrieve Analysis History from DynamoDB ----
    if method == 'GET' and path == '/analyses':
        from boto3.dynamodb.conditions import Key
        data = ddb.query(
            KeyConditionExpression=Key('PK').eq(f'USER#{user}'),
            ScanIndexForward=False
        )
        return resp(200, {'items': data.get('Items', [])})

    return resp(404, {'error': 'Not found'})


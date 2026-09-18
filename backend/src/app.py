import json, os, time, uuid, base64
import boto3
from botocore.exceptions import ClientError

s3 = boto3.client('s3')
ddb = boto3.resource('dynamodb').Table(os.environ['TABLE_NAME'])
bedrock = boto3.client('bedrock-runtime')
BUCKET = os.environ['BUCKET_NAME']

def response(code, body):
    return {
        'statusCode': code, 
        'headers': {'content-type':'application/json','access-control-allow-origin':'*'}, 
        'body': json.dumps(body)
    }

def handler(event, context):
    method = event.get('requestContext',{}).get('http',{}).get('method','GET')
    path = event.get('rawPath','/')
    user = event.get('requestContext',{}).get('authorizer',{}).get('jwt',{}).get('claims',{}).get('sub','guest')
    
    # 1. Generate Presigned URL for Image Upload
    if method == 'POST' and path == '/upload-url':
        body = json.loads(event.get('body') or '{}')
        ext = body.get('extension','jpg').lower()
        if ext not in ('jpg','jpeg','png','webp'): 
            return response(400, {'error':'Unsupported image type'})
        key = f"uploads/{user}/{uuid.uuid4()}.{ext}"
        url = s3.generate_presigned_url(
            'put_object',
            Params={'Bucket': BUCKET, 'Key': key, 'ContentType': f'image/{ext}'},
            ExpiresIn=300
        )
        return response(200, {'uploadUrl': url, 'imageKey': key})
        
    # 2. Analyze the uploaded image using Amazon Bedrock
    if method == 'POST' and path.startswith('/analyses'):
        body = json.loads(event.get('body') or '{}')
        mode = body.get('mode', 'shop')
        image_key = body.get('imageKey')
        name = body.get('name', '')
        details = body.get('details', '')
        condition = body.get('condition', '')
        
        if not image_key:
            return response(400, {'error': 'imageKey is required'})
            
        try:
            s3_obj = s3.get_object(Bucket=BUCKET, Key=image_key)
            image_bytes = s3_obj['Body'].read()
            image_base64 = base64.b64encode(image_bytes).decode('utf-8')
            
            ext = image_key.split('.')[-1].lower()
            media_type = f"image/{ext}" if ext in ['png', 'jpeg', 'webp'] else "image/jpeg"
            if ext == 'jpg': media_type = 'image/jpeg'
        except ClientError as e:
            return response(500, {'error': f"Failed to retrieve image from S3: {str(e)}"})

        if mode == "shop":
            prompt = f"""You are Sustainify AI, an expert environmental sustainability assistant.
Analyze the following product or packaging before purchase.
Product Name: {name}
Details: {details}

Based on the image and details, return a strict JSON response containing:
{{
    "type": "shop",
    "name": "{name or 'Product'}",
    "score": <integer from 0 to 100 representing Eco Score>,
    "rating": "<Excellent|Good|Average|Poor|Very Poor>",
    "confidence": <float from 0.0 to 1.0>,
    "packaging": "<analysis of visible packaging>",
    "recyclability": "<details on recyclability>",
    "positives": ["<list of positive environmental signals>"],
    "concerns": ["<list of environmental concerns>"],
    "breakdown": {{
        "Packaging": <score out of 25>,
        "Material": <score out of 25>,
        "Recyclability": <score out of 20>,
        "Reusability": <score out of 15>,
        "Product signals": <score out of 15>
    }},
    "better": "<suggestion for a better alternative>"
}}
Do NOT wrap the JSON in markdown blocks (e.g., no ```json). Just return the raw JSON object."""
        else:
            prompt = f"""You are Sustainify AI, an expert environmental sustainability assistant.
Analyze the following item after use to provide disposal or reuse guidance.
Item Name: {name}
Condition: {condition}
Details: {details}

Determine the best action from: RECYCLE, DONATE, COMPOST, SAFE DISPOSAL, REPAIR, REUSE.
Return a strict JSON response containing:
{{
    "type": "dispose",
    "name": "{name or 'Item'}",
    "action": "<The best action>",
    "confidence": <float from 0.0 to 1.0>,
    "material": "<estimated materials>",
    "category": "<Household material | Potentially hazardous household waste | etc>",
    "hazard": <true/false if it is hazardous or e-waste>,
    "steps": ["<step 1>", "<step 2>", "<step 3>"],
    "diy": "<a brief idea to repurpose or upcycle this item if safe, otherwise null>"
}}
Do NOT wrap the JSON in markdown blocks (e.g., no ```json). Just return the raw JSON object."""

        payload = {
            "anthropic_version": "bedrock-2023-05-31",
            "max_tokens": 1000,
            "messages": [
                {
                    "role": "user",
                    "content": [
                        {
                            "type": "image",
                            "source": {
                                "type": "base64",
                                "media_type": media_type,
                                "data": image_base64
                            }
                        },
                        {
                            "type": "text",
                            "text": prompt
                        }
                    ]
                }
            ]
        }

        try:
            bedrock_resp = bedrock.invoke_model(
                modelId='anthropic.claude-3-haiku-20240307-v1:0',
                contentType='application/json',
                accept='application/json',
                body=json.dumps(payload)
            )
            response_body = json.loads(bedrock_resp['body'].read())
            result_text = response_body['content'][0]['text'].strip()
            
            # Clean potential markdown formatting
            if result_text.startswith("```json"): result_text = result_text[7:]
            if result_text.startswith("```"): result_text = result_text[3:]
            if result_text.endswith("```"): result_text = result_text[:-3]
            
            ai_result = json.loads(result_text)
        except Exception as e:
            return response(500, {'error': f'Failed to generate AI response: {str(e)}'})

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
        ddb.put_item(Item=item)
        return response(201, item)
        
    # 3. Retrieve Analysis History
    if method == 'GET' and path == '/analyses':
        from boto3.dynamodb.conditions import Key
        data = ddb.query(KeyConditionExpression=Key('PK').eq(f'USER#{user}'), ScanIndexForward=False)
        return response(200, {'items': data.get('Items',[])})
        
    return response(404, {'error':'Not found'})

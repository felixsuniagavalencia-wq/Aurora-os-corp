import os, json, redis, time, hashlib
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import litellm
import os
os.environ["OPENAI_API_KEY"] = os.getenv("OPENAI_API_KEY", "")
import logging
logging.basicConfig(level=logging.DEBUG)
print("OPENAI_API_KEY=", os.getenv("OPENAI_API_KEY"))


from dotenv import load_dotenv

load_dotenv()
r = redis.Redis(host="redis", port=6379, decode_responses=True, socket_timeout=2)
app = FastAPI(title="Aurora Silent-Partner")

class DetectReq(BaseModel):
    channel: str
    text: str

class DetectRsp(BaseModel):
    intent: float
    product: str
    qty: int
    value: int
    next_action: str
    opportunity_id: str

def detect_intent(text: str) -> dict:
    prompt = f"""You are a sales-intent detector. Extract:
- intent (0-1)
- product name
- quantity
- estimated value in USD
- best next action: SEND_QUOTE | BOOK_CALL | FOLLOW_UP | NONE

Use this exact JSON format:
{{"intent": 0.85, "product": "model X", "qty": 200, "value": 24000, "next_action": "SEND_QUOTE"}}

Text: {text}"""
    try:
        response = litellm.completion(
            model="gpt-3.5-turbo",
            messages=[{"role": "user", "content": prompt}],
            temperature=0.1,
            max_tokens=120
        )
        return json.loads(response.choices[0].message.content)
    except Exception as e:
        raise HTTPException(502, str(e))

@app.post("/silent/detect", response_model=DetectRsp)
def detect(req: DetectReq):
    cache_key = hashlib.sha256(f"{req.channel}:{req.text}".encode()).hexdigest()
    # if (cached := r.get(cache_key)):
      #  return json.loads(cached)

    data = detect_intent(req.text)
    data["opportunity_id"] = f"opp_{cache_key[:8]}"
    # r.setex(cache_key, 600, json.dumps(data))  # 10 min cache
    return data

from health import router as health_router
app.include_router(health_router, tags=["health"])
@app.get("/")
def root():
    return {"message": "Aurora Silent-Partner OK"}
 

    

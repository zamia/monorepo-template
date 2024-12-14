from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
import uvicorn
import logging
import os
import argparse
import jinja2
from sqlalchemy.orm import Session
from app.db.database import get_db
from app.auth import require_auth, get_current_user_id

# Configure logging
logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger("agent-api")

# Configure argument parser
parser = argparse.ArgumentParser(description="Start the FastAPI server")
parser.add_argument(
    "-p",
    "--port",
    type=int,
    default=int(os.getenv("API_PORT", "8000")),
    help="Port to run the server on (default: 8000)",
)
parser.add_argument(
    "--env",
    default=os.getenv("APP_ENV", "development"),
    choices=["development", "production", "test"],
    help="Environment to run in (default: development)",
)

# Create FastAPI app
app = FastAPI(
    title="Agent API",
    description="API for managing AI agents and conversations",
    version="1.0.0",
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure this appropriately for production
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Setup Jinja2 environment
template_env = jinja2.Environment(loader=jinja2.FileSystemLoader("app/templates"))


@app.get("/health")
async def health_check():
    return {"status": "healthy", "version": "1.0.0"}


if __name__ == "__main__":
    args = parser.parse_args()

    logger.info(f"Starting FastAPI server on port {args.port}")
    uvicorn.run(
        "app.server:app",
        host="0.0.0.0",
        port=args.port,
        reload=args.env == "development",
        workers=3,
        log_level="debug",
    )

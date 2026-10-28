#
# BHAPI (aka BeeHappy) Application
# 
# Authors:
# Drew Kirkman
# Ryan Anderson
#

# Standard library module imports
import os, datetime, uuid, logging

# Flask and extensions
from flask import Flask, session, render_template, g
from werkzeug.middleware.proxy_fix import ProxyFix
from flask_session import Session
from flask_sqlalchemy import SQLAlchemy
import flask_migrate

# Dependencies
from redis import Redis
import sqlalchemy as sa
import sqlalchemy.orm as so

# Application metadata
from bhapi import app_meta
__version__ = app_meta.app_version

# Default config
from bhapi import default_config

# Database model
from bhapi.model import *

# Create database interface
fsa = SQLAlchemy(model_class=Base, engine_options={"pool_size": 20})

# Create Alembic controller
migrate = flask_migrate.Migrate()

# Initialize app instance
def create_app():
  app = Flask('bhapi', instance_relative_config=True)

  # Load configurations
  # Default config in application package:
  app.config.from_object(default_config)
  # From FLASK_* env variables:
  app.config.from_prefixed_env()
  # From Docker secrets
  app.config.from_pyfile('/run/secrets/bhapi_config.py', silent=True)

  # Allow BHAPI config to override default log level of WARNING
  root_logger = logging.getLogger()
  root_logger.setLevel(logging.getLevelNamesMapping()[app.config.get("BHAPI_LOG_LEVEL", "WARNING")])

  # Log startup messages
  app.logger.info(f"{app_meta.app_name} version {app_meta.app_version} started")
  app.logger.info(f"Application instance path: {app.instance_path}")
  app.logger.info(f"Package root path: {app.root_path}")
  
  # Make sure we have an instance folder
  try:
    os.makedirs(app.instance_path)
  except OSError:
    pass
  
  # Ensure a database URI is configured
  assert app.config["SQLALCHEMY_DATABASE_URI"] != "", "No SQLALCHEMY_DATABASE_URI. Ensure secrets/bhapi_config.py is configured"

  # If session defines Redis, set up the Redis object before initializing the session handler
  if app.config["SESSION_TYPE"] == "redis":
    assert app.config["SESSION_REDIS_HOST"] != "", "Redis session backend specified but no SESSION_REDIS_HOST defined"
    app.config["SESSION_REDIS"] = Redis(host=app.config["SESSION_REDIS_HOST"], port=6379)
  else:
    # Use the default Cachelib backend
    from cachelib.file import FileSystemCache
    app.config["SESSION_TYPE"] = "cachelib"
    app.config["SESSION_SERIALIZATION_FORMAT"] = "json"
    # If a persistent file share is mounted, use that instead of the default instance path
    if os.path.isdir("/bhapi/persistent"):
      app.logger.info("Using persistent storage for FileSystemCache backed sessions")
      app.config["SESSION_CACHELIB"] = FileSystemCache(cache_dir="/bhapi/persistent/sessions")
    else:
      app.logger.info("Using temporary storage for FileSystemCache backed sessions")
      app.config["SESSION_CACHELIB"] = FileSystemCache(cache_dir=app.instance_path + "/sessions")
  
  Session(app)

  # Implement proxyfix for when running the dev server or behind nginx
  app.wsgi_app = ProxyFix(app.wsgi_app, x_proto=1, x_host=1, x_for=1, x_prefix=1)

  # Make several useful objects available from every template
  @app.context_processor
  def inject_template_vars():
    useful_info = {
      "datetime_utc": datetime.datetime.now(datetime.UTC),
      "application_mode": app.config["BHAPI_APPLICATION_MODE"],
      "null_uuid": str(uuid.UUID(int=0))
    }
    return dict(app_meta=app_meta, useful_info=useful_info)
  
  # Actions to take before every request
  @app.before_request
  def preload_actions():
    pass
  
  # Initialize database pool
  fsa.init_app(app)

  # Register Alembic controller
  migrate.init_app(app, fsa)

  # Common pages blueprint
  from bhapi.common import bp as common_bp
  app.register_blueprint(common_bp)

  # API blueprint
  from bhapi.api import bp as api_bp
  app.register_blueprint(api_bp)

  # PayPal blueprint
  from bhapi.paypal import bp as paypal_bp
  app.register_blueprint(paypal_bp)
    
  return app
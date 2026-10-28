from flask import Blueprint

bp = Blueprint("api", __name__, url_prefix="/api")

from bhapi.api import routes

__all__ = [
  "routes",
]
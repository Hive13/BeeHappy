from flask import Blueprint

bp = Blueprint("api", __name__, url_prefix="/paypal")

from bhapi.paypal import routes

__all__ = [
  "routes",
]
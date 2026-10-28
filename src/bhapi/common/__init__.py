from flask import Blueprint

bp = Blueprint("common", __name__, template_folder="templates")

from bhapi.common import routes

__all__ = [
  "routes",
]
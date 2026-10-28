from flask import g, url_for, session

from bhapi.common import bp
from bhapi import app_meta

@bp.route("/")
def api_info():
  return {"app_meta": {"app_name": app_meta.app_name, "app_version": app_meta.app_version}}

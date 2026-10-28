from flask import g, url_for, session

from bhapi.api import bp
from bhapi import app_meta

@bp.route("/access")
def api_info():
  pass
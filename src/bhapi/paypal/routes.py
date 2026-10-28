from flask import g, url_for, session

from bhapi.paypal import bp
from bhapi import app_meta

@bp.route("/ipn")
def paypal_ipn():
  pass
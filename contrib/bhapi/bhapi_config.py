# This bhapi_config.py template contains the minimum values 
# needed to be defined for the BHAPI application to function.
#
# Save this file as secrets/bhapi_config.py (relative to the 
# repository root) and replace the values as needed.

# PostgreSQL connection string
SQLALCHEMY_DATABASE_URI="postgresql://user:pass@server:port/database"

# OAuth 2.0 client secret
CLIENT_SECRET="..."
# EXPIRES MM/DD/YYYY (this is a helpful message to include)

# BHAPI application mode
# THIS MUST BE SET TO SOMETHING OTHER THAN "test" OR THE APPLICATION
# WILL RUN IN SINGLE-USER MODE
BHAPI_APPLICATION_MODE="production"
import os

from pyramid.config import Configurator
from sqlalchemy import engine_from_config

from atramhasis.data.models import Base


def main(global_config, **settings):
    """This function returns a Pyramid WSGI application."""

    # Set up sqlalchemy
    engine = engine_from_config(settings, "sqlalchemy.")
    Base.metadata.bind = engine

    # set up dump location
    dump_location = settings["atramhasis.dump_location"]
    if not os.path.exists(dump_location):
        os.makedirs(dump_location)

    with Configurator(settings=settings) as config:
        # Set up atramhasis
        config.include("atramhasis")
        # Set up atramhasis db
        config.include("atramhasis:data.db")

        config.override_asset(
            to_override='atramhasis:templates/welcome.jinja2',
            override_with='meemoo_atramhasis:templates/welcome.jinja2'
        )

        config.override_asset(
            to_override='atramhasis:templates/conceptscheme.jinja2',
            override_with='meemoo_atramhasis:templates/conceptscheme.jinja2'
        )

        config.override_asset(
            to_override='atramhasis:templates/conceptschemes_overview.jinja2',
            override_with='meemoo_atramhasis:templates/conceptschemes_overview.jinja2'
        )

        config.override_asset(
            to_override="atramhasis:static/css/app.css",
            override_with="meemoo_atramhasis:static/css/app.css",
        )

        config.scan()
        return config.make_wsgi_app()

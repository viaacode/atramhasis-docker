FROM python:3.12-alpine
ARG branch=main
# The latest alpine images don't have some tools like (`git` and `bash`).
# Adding bash and openssh to the image
RUN apk update && apk upgrade && \
    apk add --no-cache bash openssh nodejs npm

COPY . /app/atramhasis

WORKDIR /app/atramhasis

RUN pip install atramhasis==2.1.1

# Generate custom
RUN npm install -g sass
RUN cd ./meemoo_atramhasis/static && sass -I /usr/local/lib/python3.12/site-packages/atramhasis/static/scss -I /usr/local/lib/python3.12/site-packages/atramhasis/static/node_modules/foundation-sites/scss -I /usr/local/lib/python3.12/site-packages/atramhasis/static/node_modules/font-awesome/scss --embed-source-map --quiet scss/app.scss css/app.css

RUN pip install -e .[dev]

# create or update database
RUN alembic upgrade head

# Add SKOS data
RUN mkdir /data
COPY data.csv /data
RUN bash load.sh

EXPOSE 6543

RUN addgroup --system appgroup && adduser --system appuser --ingroup appgroup

RUN chown -R appuser:appgroup /app/atramhasis &&  chown -R appuser:appgroup /home/appuser/.local/

USER appuser

CMD ["pserve", "development.ini"] 
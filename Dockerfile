FROM python:3.8-alpine
# The latest alpine images don't have some tools like (`git` and `bash`).
# Adding git, bash and openssh to the image
RUN apk update && apk upgrade && \
    apk add --no-cache bash git openssh
RUN mkdir /app

RUN git clone https://github.com/OnroerendErfgoed/atramhasis /app/atramhasis
WORKDIR /app/atramhasis
# Install dependencies
RUN pip install -r requirements-dev.txt
# Install packages in dev mode
RUN pip install -e .
# create or update database
RUN alembic upgrade head
# insert sample data
RUN initialize_atramhasis_db development.ini
# generate first RDF download
RUN dump_rdf development.ini
# compile the Message Catalog Files
RUN python setup.py compile_catalog
EXPOSE 6543
CMD ["pserve", "development.ini"] 

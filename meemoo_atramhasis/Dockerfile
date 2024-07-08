FROM python:3.12-alpine
# The latest alpine images don't have some tools like (`git` and `bash`).
# Adding bash and openssh to the image
RUN apk update && apk upgrade && \
    apk add --no-cache bash openssh nodejs npm

COPY . /app/atramhasis

WORKDIR /app/atramhasis

RUN pip install -e .[dev]

# create or update database
RUN alembic upgrade head

# Add SKOS data
RUN mkdir /data
COPY data.csv /data
RUN  <<EOF
while IFS="," read -r skos_file namespace
do
    filename="${skos_file##*/}"
    wget https://raw.githubusercontent.com/viaacode/datamodels/main/$skos_file
    import_file $filename $namespace
    rm $filename
done < /data/data.csv
EOF

EXPOSE 6543
CMD ["pserve", "development.ini"] 
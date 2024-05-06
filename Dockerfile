FROM python:3.11-alpine
# The latest alpine images don't have some tools like (`git` and `bash`).
# Adding git, bash and openssh to the image
RUN apk update && apk upgrade && \
    apk add --no-cache bash git openssh nodejs npm
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
COPY config.ini config.ini
#RUN initialize_atramhasis_db config.ini
# compile the Message Catalog Files
RUN python setup.py compile_catalog
#
RUN npm install -g grunt-cli
# install js dependencies for public site using npm
RUN cd atramhasis/static && npm install
# install js dependencies for admin using npm
RUN cd atramhasis/static/admin && npm install 
#&& grunt -v build
# 
RUN mkdir /data
COPY data.csv /data
RUN  <<EOF
git clone https://github.com/viaacode/datamodels 
while IFS="," read -r skos_file namespace
do
    import_file datamodels/$skos_file $namespace
done < /data/data.csv
EOF
#&& grunt -v build
EXPOSE 6543
CMD ["pserve", "config.ini"] 

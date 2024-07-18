FROM python:3.12-alpine
# The latest alpine images don't have some tools like (`git` and `bash`).
# Adding git, bash and openssh to the image
RUN apk update && apk upgrade && \
    apk add --no-cache bash git openssh curl openjdk11 nodejs npm
# RUN  <<EOF
# # installs nvm (Node Version Manager)
# curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# # download and install Node.js (you may need to restart the terminal)
# nvm install 22

# # verifies the right Node.js version is in the environment
# node -v # should print `v22.4.1`

# # verifies the right NPM version is in the environment
# npm -v # should print `10.8.1`
# EOF
# Install grunt first
RUN npm install -g grunt-cli
RUN pip install --upgrade pip pip-tools
RUN mkdir /app

RUN git clone https://github.com/OnroerendErfgoed/atramhasis /app/atramhasis
WORKDIR /app/atramhasis

# Install dependencies
RUN pip-sync requirements-dev.txt
# Install packages in dev mode
RUN pip install -e .
# create or update database
RUN alembic upgrade head
# insert sample data
COPY config.ini config.ini
#RUN initialize_atramhasis_db config.ini
RUN pybabel compile --directory 'atramhasis/locale' --domain atramhasis --statistics true

# Add SKOS data
RUN mkdir /data
COPY data.csv /data
RUN  <<EOF
git clone https://github.com/viaacode/datamodels 
while IFS="," read -r skos_file namespace
do
    import_file datamodels/$skos_file $namespace
done < /data/data.csv
EOF

EXPOSE 6543
CMD ["pserve", "config.ini"] 

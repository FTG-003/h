FROM gliderlabs/alpine:3.2
MAINTAINER Hypothes.is Project and contributors

# Update the base image and install runtime dependencies.
RUN apk update \
  && apk upgrade \
  && apk add ca-certificates libffi libpq python nodejs ruby

# Create the hypothesis user, group, home directory and package directory.
RUN addgroup -S hypothesis \
  && adduser -S -G hypothesis -h /var/lib/hypothesis hypothesis
WORKDIR /var/lib/hypothesis

# Copy packaging
COPY h/_version.py ./h/
COPY package.json setup.* requirements.txt versioneer.py ./

# These files must exist to satisfy setup.py.
RUN touch CHANGES.txt README.rst

# Install build dependencies, build, then clean up.
RUN apk add --virtual build-deps \
    libffi-dev \
    g++ \
    make \
    postgresql-dev \
    python-dev \
    ruby-dev \
  && apk add py-pip \
  && gem install --no-ri compass \
  && npm install --production \
  && pip install --no-cache-dir -U pip \
  && pip install --no-cache-dir -r requirements.txt \
  && apk del build-deps postgresql-dev \
  && npm cache clean \
  && rm -rf /tmp/* /var/cache/apk/*

# Copy the rest of the application files
COPY Procfile gunicorn.conf.py ./
COPY conf ./conf/
COPY h ./h/

# Change ownership of all the files and switch to the hypothesis user.
RUN chown -R hypothesis:hypothesis .
USER hypothesis

# Expose the default port.
EXPOSE 5000

# Persist the static directory.
VOLUME ["/var/lib/hypothesis/h/static"]

# Use honcho and start all the daemons by default.
ENTRYPOINT ["honcho"]
CMD ["start", "-c", "all=1,assets=0,initdb=0"]

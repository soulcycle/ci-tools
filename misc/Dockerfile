FROM alpine:3.7
LABEL maintainer="Marcus Bastian <marcus.bastian@soul-cycle.com>"

ADD requirements.txt /usr/src/app/requirements.txt
ADD *.py /usr/src/app/
ADD .ansible.cfg /root/.ansible.cfg

WORKDIR /usr/src/app

RUN apk add --update jq \
        recode \
        python3 \
        python3-dev \
        py-pip

# Add compilers and other related libs
RUN apk add gcc \
        libffi-dev \
        openssl-dev \
        musl-dev \
        build-base \
        bash \
    && rm -rf /var/cache/apk/*

# Lock down config
RUN chmod 0600 /root/.ansible.cfg

# Upgrade pip and install virtualenv
RUN pip3 install --upgrade pip \
    && pip3 install virtualenv --no-cache-dir

# Instantiate Python 3.6 virtual env
RUN virtualenv /env --python=/usr/bin/python3.6 \
    && pip3 install -r requirements.txt

CMD [ "/usr/bin/python3.6", "/usr/src/app/inspect-k8s-manifests.py"]

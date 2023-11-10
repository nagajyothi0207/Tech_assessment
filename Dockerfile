FROM hashicorp/terraform:1.5

WORKDIR /app
ENV USER="root"
ENV PATH="${PATH}:/home/root/.local/bin"
ENV LOCALSTACK_HOSTNAME="localstack"
ENV AWS_ACCESS_KEY_ID="test"
ENV AWS_SECRET_ACCESS_KEY="test"
ENV AWS_DEFAULT_REGION="ap-southeast-1"

RUN apk add python3 py3-pip make curl jq

USER root

RUN pip3 install awscli
RUN pip3 install terraform-local

COPY config/.aws /app/.aws
COPY config/.aws /root/.aws

ENTRYPOINT ["tail", "-f", "/dev/null"]

FROM python:3.14-alpine

RUN pip3 install --upgrade pip && \
  pip3 install pyflakes && \
  rm -r /root/.cache

ENV SHELLCHEK_VERSION=v0.11.0
RUN set -x; \
  arch="$(uname -m)"; \
  echo "arch is $arch"; \
  if [ "${arch}" = 'armv7l' ]; then \
  arch='armv6hf'; \
  fi; \
  url_base='https://github.com/koalaman/shellcheck/releases/download/'; \
  tar_file="${SHELLCHEK_VERSION}/shellcheck-${SHELLCHEK_VERSION}.linux.${arch}.tar.xz"; \
  wget "${url_base}${tar_file}" -O - | tar xJf -; \
  mv "shellcheck-${SHELLCHEK_VERSION}/shellcheck" /bin/; \
  rm -rf "shellcheck-${SHELLCHEK_VERSION}"; \
  ls -laF /bin/shellcheck

RUN apk --update add bash git curl && \
  rm -rf /var/lib/apt/lists/* && \
  rm /var/cache/apk/*

# install reviewdog
ENV REVIEWDOG_VERSION=v0.21.0
RUN wget -q -O /tmp/install-reviewdog.sh https://raw.githubusercontent.com/reviewdog/reviewdog/fd59714416d6d9a1c0692d872e38e7f8448df4fc/install.sh && \
  sh /tmp/install-reviewdog.sh -b /usr/local/bin/ ${REVIEWDOG_VERSION} && \
  rm /tmp/install-reviewdog.sh

# install actionlint
ENV ACTIONLINT_VERSION=1.7.11
ENV OSTYPE=linux-gnu
RUN wget -q -O /tmp/download-actionlint.bash https://raw.githubusercontent.com/rhysd/actionlint/main/scripts/download-actionlint.bash && \
  cd /usr/local/bin/ && sh /tmp/download-actionlint.bash ${ACTIONLINT_VERSION} && \
  rm /tmp/download-actionlint.bash

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

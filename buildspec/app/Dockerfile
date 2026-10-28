FROM alpine:latest

ARG UID=24274
ARG USER=bhapi
ENV HOME /home/${USER}

RUN apk add --update --no-cache python3 python3-dev py3-pip py3-cffi py3-gpep517 py3-installer git gcc libffi-dev libc-dev tzdata && adduser -u ${UID} -D ${USER}

COPY --chown=${USER}:${USER} --chmod=755 ./buildspec/app/bhapi.entrypoint.sh ${HOME}
COPY --chown=${USER}:${USER} ./pyproject.toml ${HOME}
COPY --chown=${USER}:${USER} ./MANIFEST.in ${HOME}
COPY --chown=${USER}:${USER} ./buildspec/app/gunicorn.docker.conf.py ${HOME}/gunicorn.conf.py
COPY --chown=${USER}:${USER} ./src ${HOME}/src
COPY --chown=${USER}:${USER} ./migrations ${HOME}/migrations

VOLUME [ "${HOME}/uploads" ]

USER ${USER}
WORKDIR ${HOME}

RUN python3 -m venv .venv && . .venv/bin/activate && exec pip3 install . && deactivate

ENTRYPOINT [ "/home/bhapi/bhapi.entrypoint.sh" ]
CMD [ "gunicorn" ]
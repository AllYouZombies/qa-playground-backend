FROM oshpalov/python:3.10-slim-bullseye AS base

FROM base AS deps

RUN --mount=type=bind,source=requirements.txt,target=requirements.txt \
    --mount=type=cache,target=/root/.cache/pip \
    python -m venv /venv \
    && . /venv/bin/activate \
    && pip install -r requirements.txt

FROM base AS runtime

RUN useradd --create-home django

USER django

WORKDIR /home/django

COPY --from=deps --chown=django:django /venv /venv

ENV PATH="/venv/bin:$PATH"

COPY --chown=django:django . .

RUN chmod +x /home/django/docker/entrypoint.sh

ENTRYPOINT ["/home/django/docker/entrypoint.sh"]

CMD ["gunicorn"]

EXPOSE 8000

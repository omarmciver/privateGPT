### IMPORTANT, THIS IMAGE CAN ONLY BE RUN IN LINUX DOCKER
### You will run into a segfault in mac
FROM python:3.11.6-slim-bookworm as base

# Install poetry
RUN pip install pipx
RUN python3 -m pipx ensurepath
RUN pipx install poetry
ENV PATH="/root/.local/bin:$PATH"

# Dependencies to build llama-cpp
RUN apt update && apt install -y \
  libopenblas-dev\
  ninja-build\
  build-essential\
  pkg-config\
  wget

# https://python-poetry.org/docs/configuration/#virtualenvsin-project
ENV POETRY_VIRTUALENVS_IN_PROJECT=true

FROM base as dependencies
WORKDIR /home/root/app
COPY pyproject.toml poetry.lock ./

RUN poetry install --with local
RUN poetry install --with ui

FROM base as app

ENV PYTHONUNBUFFERED=1
ENV PORT=8080
EXPOSE 8080

# Prepare a non-root user
# RUN adduser --system worker
WORKDIR /home/root/app

RUN mkdir local_data; chown root local_data
RUN mkdir models; chown root models
COPY --chown=root --from=dependencies /home/root/app/.venv/ .venv
COPY --chown=root private_gpt/ private_gpt
COPY --chown=root docs/ docs
COPY --chown=root *.yaml *.md ./
COPY --chown=root scripts/ scripts
COPY startup.sh .
RUN chmod +x startup.sh

ENV MPLCONFIGDIR=/tmp/matplotlib_cache
RUN mkdir -p "$MPLCONFIGDIR"
USER root
ENTRYPOINT ["startup.sh"]
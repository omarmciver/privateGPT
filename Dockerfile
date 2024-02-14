### IMPORTANT, THIS IMAGE CAN ONLY BE RUN IN LINUX DOCKER
### You will run into a segfault in mac
FROM python:3.11.6-slim-bookworm AS base

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

FROM base AS dependencies
WORKDIR /home/root/app
# Copy only pyproject.toml and poetry.lock to cache dependencies installation
COPY pyproject.toml poetry.lock ./
ENV PIP_DEFAULT_TIMEOUT=1000
ENV POETRY_CACHE_DIR=/poetry_cache

# Install dependencies
RUN --mount=type=cache,target=$POETRY_CACHE_DIR poetry install --with local
RUN --mount=type=cache,target=$POETRY_CACHE_DIR poetry install --with ui

FROM base AS app

ENV PYTHONUNBUFFERED=1
ENV PORT=8080
EXPOSE 8080

WORKDIR /home/root/app

# Create necessary directories
RUN mkdir local_data models
RUN chown root:root local_data models

# Copy the virtual environment
COPY --chown=root --from=dependencies /home/root/app/.venv/ .venv

# Now copy the rest of the app
COPY --chown=root private_gpt/ private_gpt
# COPY --chown=root docs/ docs
COPY --chown=root *.yaml *.md ./
COPY --chown=root scripts/ scripts
COPY startup.sh .

# Set permissions for startup script
RUN chmod +x startup.sh

# Set up matplotlib cache directory
ENV MPLCONFIGDIR=/tmp/matplotlib_cache
RUN mkdir -p "$MPLCONFIGDIR"

# Run as root user
USER root

# Define the entrypoint
ENTRYPOINT ["./startup.sh"]

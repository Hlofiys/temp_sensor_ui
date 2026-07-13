# Find builder and runner images on Docker Hub or on Hex's Build Server (Bob).
# We recommend using Bob's Web UI to find recent tags:
#   - https://bob.hex.pm/docker

ARG ELIXIR_VERSION=1.20.2
ARG OTP_VERSION=28.5.0.3
ARG ALPINE_VERSION=3.24.1

ARG BUILDER_IMAGE="docker.io/hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-alpine-${ALPINE_VERSION}"
ARG RUNNER_IMAGE="docker.io/alpine:${ALPINE_VERSION}"

FROM ${BUILDER_IMAGE} AS builder

# install build dependencies (apk instead of apt-get)
# build-base is Alpine's equivalent to Debian's build-essential
RUN apk add --no-cache build-base git

# prepare build dir
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force \
  && mix local.rebar --force

# set build ENV
ENV MIX_ENV="prod"

# install mix dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mkdir config

# copy compile-time config files before we compile dependencies
# to ensure any relevant config change will trigger the dependencies
# to be re-compiled.
COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.compile

RUN mix assets.setup

COPY priv priv

COPY lib lib

# Compile the release
RUN mix compile

COPY assets assets

# compile assets
RUN mix assets.deploy

# Changes to config/runtime.exs don't require recompiling the code
COPY config/runtime.exs config/

COPY rel rel
RUN mix release

# start a new build stage so that the final image will only contain
# the compiled release and other runtime necessities
FROM ${RUNNER_IMAGE} AS final

# Install runtime dependencies for Alpine
# ncurses-libs replaces libncurses6
RUN apk add --no-cache libstdc++ openssl ncurses-libs ca-certificates

# Alpine doesn't use locale-gen like Debian. It natively supports UTF-8 via musl libc.
# We just need to set the environment variables.
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

WORKDIR "/app"
RUN mkdir -p /data && chown nobody:nobody /data
RUN chown nobody /app

# set runner ENV
ENV MIX_ENV="prod"

# Only copy the final release from the build stage
COPY --from=builder --chown=nobody:root /app/_build/${MIX_ENV}/rel/temp_sensor_ui ./

USER nobody

# If using an environment that doesn't automatically reap zombie processes, it is
# advised to add an init process such as tini via `apk add --no-cache tini`
# above and adding an entrypoint. See https://github.com/krallin/tini for details
# ENTRYPOINT ["/sbin/tini", "--"]

CMD ["/app/bin/server"]
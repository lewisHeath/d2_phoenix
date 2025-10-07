FROM ubuntu:latest

RUN apt update && apt install -y elixir

RUN mix local.hex --force && \
    mix local.rebar --force

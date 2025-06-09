FROM ruby:3.3.7

# Install build dependencies and SQLite development libraries
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libsqlite3-dev

# Create a non-root user "vscode"
RUN useradd -ms /bin/bash vscode

# Set the working directory and change ownership to the vscode user
WORKDIR /workspace
RUN chown -R vscode:vscode /workspace

# Switch to the non-root user
USER vscode

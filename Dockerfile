FROM node:22

# Verify installation
RUN yarn -v

WORKDIR /app

# Install dependencies (if package.json is in the mounted directory)
COPY ./package.json ./yarn.lock ./
RUN yarn install

COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh
# Start with the command specified in docker-compose.yml

CMD ["bash"]
# Keeps it running so you can exec into it
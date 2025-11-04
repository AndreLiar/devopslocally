FROM node:20-alpine
WORKDIR /app
COPY . .
RUN npm install express   # or remove if not needed
EXPOSE 3000
CMD ["node", "server.js"]

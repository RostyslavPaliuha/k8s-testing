FROM python:3.13-alpine

WORKDIR /app

COPY index.html ui-server.py ./

ENV HOST=0.0.0.0
ENV PORT=8080

EXPOSE 8080

CMD ["python", "ui-server.py"]

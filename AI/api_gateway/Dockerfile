FROM nginx:latest

COPY gateway.conf /etc/nginx/nginx.conf

EXPOSE 80 443
ENTRYPOINT ["nginx"]
CMD ["-g", "daemon off;"]

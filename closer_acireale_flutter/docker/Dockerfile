# Dockerfile per build web di produzione
FROM nginx:alpine

# Copia i file di build nella directory nginx
COPY build/web /usr/share/nginx/html

# Copia la configurazione nginx personalizzata
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf

# Esponi la porta 80
EXPOSE 80

# Comando di avvio
CMD ["nginx", "-g", "daemon off;"]
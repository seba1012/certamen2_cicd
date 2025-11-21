# 1. ETAPA DE CONSTRUCCIÓN
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
# Asumiendo que necesita dependencias y construcción
RUN npm install
COPY . .

# 2. ETAPA DE EJECUCIÓN/PRODUCCIÓN
FROM node:18-alpine
WORKDIR /app
# Copiar solo lo necesario desde la etapa de construcción
COPY --from=builder /app .
# El puerto 3000 es común para este tipo de aplicaciones
EXPOSE 3000 
CMD ["npm", "start"]
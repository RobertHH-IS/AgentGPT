# Use the official Node.js image as the base image
FROM node:24.22.1-alpine@sha256:6a1c190e17215d844926b0677f4bf87273ff7d5e54db06d3b5b5863ab0b09a3d

# Set the working directory
WORKDIR /app

# Copy package.json and package-lock.json to the working directory
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy the rest of the application code
COPY . .
RUN mv .env.docker .env  \
    && sed -ie 's/postgresql/sqlite/g' prisma/schema.prisma \
   && sed -ie 's/@db.Text//' prisma/schema.prisma

# Expose the port the app will run on
EXPOSE 3000

# Add Prisma and generate Prisma client
RUN npx prisma generate  \
    && npx prisma migrate dev --name init  \
    && npx prisma db push

# Build the Next.js app
RUN npm run build


# Start the application
CMD ["npm", "start"]

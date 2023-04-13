#!/bin/bash
cd "$(dirname "$0")" || exit

if [ "$1" = "--skipenv" ]; then

echo -n "Enter your OpenAI Key (eg: sk...): "
read OPENAI_API_KEY

NEXTAUTH_SECRET=$(openssl rand -base64 32)

ENV="NODE_ENV=development\n\
NEXTAUTH_SECRET=$NEXTAUTH_SECRET\n\
NEXTAUTH_URL=https://agentgpt.doodkin.com\n\
OPENAI_API_KEY=$OPENAI_API_KEY\n\
DATABASE_URL=file:../db/db.sqlite\n"
printf $ENV > .env

fi

if [ "$1" = "--docker" ]; then
  cp .env .env.docker
  docker build -t agentgpt .
  docker run -d --name agentgpt -p 10280:3000 -v $(pwd)/db:/app/db agentgpt
elif [ "$1" = "--devdocker" ]; then
  docker run -dti --name agentgpt -p 10280:3000 -v $(pwd)/:/app/ node:bullseye bash /app/setup.sh --skipenv
else
  ./prisma/useSqlite.sh
  npm install
  npm run dev
fi


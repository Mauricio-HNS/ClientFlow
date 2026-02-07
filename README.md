# ClientFlow

App modular para gerenciamento de clientes, agendamentos e relacionamento com tres perfis: **Cliente**, **Salao** e **Admin**.

## Visao Geral
- **Cliente (B2C):** agenda servicos, recebe lembretes e conversa com o salao.
- **Salao (B2B):** gerencia agenda, clientes, equipe e conversas.
- **Admin (SaaS):** administra saloes, planos e metricas globais.

## Stack
- **Mobile:** Flutter
- **Backend:** ASP.NET Core + EF Core + SignalR
- **Banco:** PostgreSQL
- **Auth:** JWT + roles

## Fluxo do App do Cliente
1. **Splash**
2. **Login/Cadastro**
3. **Home**

## Contas de teste (seed)
- **Admin**: `admin@clientflow.local` / `admin123`
- **Salao**: `salao@clientflow.local` / `salao123`
- **Cliente**: `cliente@clientflow.local` / `cliente123`

## Subir Postgres (Docker)
```bash
docker rm -f clientflow-postgres

docker run --name clientflow-postgres \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=clientflow \
  -p 5433:5432 \
  -d postgres:16
```

## Rodar a API
```bash
cd "/Users/mauriciohenrique/Projects/ClientFlow/services/api"
dotnet run
```

## Rodar o App Mobile
```bash
cd "/Users/mauriciohenrique/Projects/ClientFlow/apps/mobile"
flutter run --dart-define=CLIENTFLOW_API_URL=http://127.0.0.1:5078
```

## API (resumo)
- `POST /auth/register` (email, password, name, phone, role)
- `POST /auth/login` (email, password)
- `GET /clients` (auth)
- `POST /clients` (auth)
- `GET /appointments` (auth)
- `POST /appointments` (auth)
- `GET /conversations` (auth)
- `POST /conversations/{id}/messages` (auth)
- `GET /conversations/{id}/messages` (auth)

## Chat em tempo real
- SignalR hub: `ws://<API>/hubs/chat`
- Mensagens transmitidas por evento `message:new`

## Documentacao
- `docs/PRODUCT.md`
- `docs/PITCH.md`


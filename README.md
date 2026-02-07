# ClientFlow

Ecossistema com 3 apps separados e um backend unico:
- **Cliente (B2C):** `apps/client`
- **Salao (B2B):** `apps/salon`
- **Admin/Painel (SaaS):** `apps/admin`

## Visao Geral
- **Cliente (B2C):** agenda servicos, recebe lembretes e conversa com o salao.
- **Salao (B2B):** gerencia agenda, clientes, equipe e conversas.
- **Admin (SaaS):** administra saloes, planos e metricas globais, incluindo bloqueio por inadimplencia.

## Stack
- **Mobile:** Flutter
- **Backend:** ASP.NET Core + EF Core + SignalR
- **Banco:** PostgreSQL
- **Auth:** JWT + roles (client, salon, admin)

## Fluxo do App do Cliente
1. **Splash**
2. **Login/Cadastro**
3. **Home**

## Contas de teste (seed)
Use estas credenciais no login:
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

## Rodar os Apps
### Cliente
```bash
cd "/Users/mauriciohenrique/Projects/ClientFlow/apps/client"
flutter run --dart-define=CLIENTFLOW_API_URL=http://127.0.0.1:5078
```

### Salao
```bash
cd "/Users/mauriciohenrique/Projects/ClientFlow/apps/salon"
flutter run --dart-define=CLIENTFLOW_API_URL=http://127.0.0.1:5078
```

### Admin/Painel
```bash
cd "/Users/mauriciohenrique/Projects/ClientFlow/apps/admin"
flutter run --dart-define=CLIENTFLOW_API_URL=http://127.0.0.1:5078
```

## Teste de bloqueio do salao
1. Entre no **Admin** com `admin@clientflow.local / admin123`
2. Va em **Saloes** e marque o salao como **Suspenso**
3. No app do **Salao**, ele sera bloqueado automaticamente

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

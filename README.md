# MADSAG Backend — Strapi CMS

Custom Strapi v5 backend for **madsag.in**, hosted at **api.madsag.in**.

## 📁 Content Types

| Type | API Endpoint | Kind |
|---|---|---|
| Blog Post | `/api/blog-posts` | Collection |
| Portfolio Item | `/api/portfolio-items` | Collection |
| Lead | `/api/leads` | Collection |
| Global | `/api/global` | Single Type |

---

## 🚀 Local Development (SQLite)

```bash
# 1. Install dependencies
npm install

# 2. Use the dev .env (SQLite — already configured)
# DATABASE_CLIENT=sqlite, DATABASE_FILENAME=.tmp/data.db

# 3. Start dev server
npm run develop

# → Opens at http://localhost:1337/admin
# → Create your first admin account on first run
```

---

## 🌐 Production Deployment (PostgreSQL @ api.madsag.in)

### Step 1 — Provision a PostgreSQL database
Create a PostgreSQL database on your server (or use Supabase/Railway/Neon):
```sql
CREATE DATABASE madsag_strapi;
CREATE USER strapi WITH ENCRYPTED PASSWORD 'your_strong_password';
GRANT ALL PRIVILEGES ON DATABASE madsag_strapi TO strapi;
```

### Step 2 — Set up production .env
Copy `.env.example` to `.env` on the server and fill in your values:
```bash
cp .env.example .env
nano .env
```

Set these values:
```env
DATABASE_CLIENT=postgres
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_NAME=madsag_strapi
DATABASE_USERNAME=strapi
DATABASE_PASSWORD=your_strong_password
DATABASE_SSL=false
```

Or use a single connection string:
```env
DATABASE_URL=postgresql://strapi:your_strong_password@localhost:5432/madsag_strapi
```

### Step 3 — Generate fresh secrets
```bash
node -e "for(let i=0;i<6;i++) console.log(require('crypto').randomBytes(16).toString('base64'))"
```
Paste the generated values into `.env` for: `APP_KEYS`, `API_TOKEN_SALT`, `ADMIN_JWT_SECRET`, `JWT_SECRET`, `TRANSFER_TOKEN_SALT`, `ENCRYPTION_KEY`

### Step 4 — Build and start
```bash
npm run build
npm run start
# → Runs on PORT 1337
```

### Step 5 — Set Permissions in Strapi Admin
Go to `http://api.madsag.in/admin` → **Settings → Users & Permissions → Roles**:

**Public Role:**
| Content Type | Permissions |
|---|---|
| Blog Post | `find`, `findOne` |
| Portfolio Item | `find`, `findOne` |
| Lead | `create` |
| Global | `find` |

**Authenticated Role:**
| Content Type | Permissions |
|---|---|
| Blog Post | `find`, `findOne`, `create`, `update`, `delete` |
| Portfolio Item | `find`, `findOne`, `create`, `update`, `delete` |
| Lead | `find`, `findOne` |
| Global | `find`, `update` |

---

## 🔗 Frontend Connection

The frontend SPA at `madsag-spa-main/` points to `https://api.madsag.in` via:
```
madsag-spa-main/constants.tsx → STRAPI_URL = "https://api.madsag.in/"
```

CORS is pre-configured in `config/middlewares.ts` to allow:
- `https://madsag.in`
- `https://www.madsag.in`
- `http://localhost:5173`

---

## 📦 Tech Stack

- **Strapi** v5.50.2
- **Database:** SQLite (dev) / PostgreSQL (production)
- **Node.js** ≥ 20.x

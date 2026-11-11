# TROUBLESHOOTING - ZENO ERP

## Erro 500 no Render

### Causas comuns:

1. **APP_KEY não está definida**
   - No painel do Render, adicione: `APP_KEY=base64:...` (32 caracteres)
   - Gere localmente: `php artisan key:generate`

2. **Variáveis de conexão com Supabase erradas**
   - `DB_HOST`, `DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD`
   - Para Render: use o connection string do Supabase

3. **Permissões de storage**
   - O Render usa disco efêmero - uploads vão para Supabase Storage

### Solução rápida:

No painel do Render → Environment → Add:
```
APP_KEY=base64:your-32-char-key-here
DB_HOST=db.supabase.co
DB_PORT=5432
DB_DATABASE=postgres
DB_USERNAME=your-ref-project-id
DB_PASSWORD=your-db-password
SESSION_DRIVER=database
QUEUE_CONNECTION=database
CACHE_STORE=database
```

## Erro de conexão no LXC

### Causas:

1. **Banco não foi migrado**
   - O arquivo de migração NÃO substitui o SQL do schema do Supabase
   - Você deve executar `php artisan migrate --force` no LXC

2. **Schema errado**
   - Verifique se `DB_SCHEMA` está apontando para a tabela correta
   - O schema do Supabase precisa ter todas as 41 tabelas do `01_schema_supabase.sql`

### Solução:

No LXC:
```bash
# 1. Acesse o diretório
cd /var/www/zeno-erp-develop

# 2. Execute migrações (force é obrigatório em ambiente de produção)
php artisan migrate --force

# 3. Seed admin (opcional, para teste)
php artisan db:seed --force
```

## Verificação de saúde

- **Render**: `https://seu-app.onrender.com/health` → deve retornar `{"status":"ok","app":"ZENO ERP",...}`
- **LXC**: `http://seu-lxc:8000/health` (ou porta configurada)

## Logs

Render: `/var/log/nginx/error.log` via console
LXC: `tail -f /var/log/php-fpm.log` ou `journalctl -u php-fpm`
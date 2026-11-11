<div align="center">

# ZENO ERP

### Gestão em equilíbrio para pequenos negócios

**Sistema de gestão empresarial para pequenas lojas, prestadores de serviços e microempreendedores individuais.**

[![PHP](https://img.shields.io/badge/PHP-8.2%2B-777BB4?logo=php&logoColor=white)](https://www.php.net/)
[![Laravel](https://img.shields.io/badge/Laravel-11-FF2D20?logo=laravel&logoColor=white)](https://laravel.com/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-Database-4169E1?logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![Status](https://img.shields.io/badge/Status-Em%20desenvolvimento-DAA520)](#status-do-projeto)

</div>

---

## Visão geral

O **Zeno ERP** é um projeto de software de gestão empresarial desenvolvido com **PHP e Laravel**. Seu objetivo é apoiar a organização de processos de pequenos negócios em uma aplicação centralizada, com uma base técnica preparada para evolução contínua.

O repositório inclui configurações para integração com **PostgreSQL/Supabase**, execução com **Docker** e arquivos relacionados a **deploy e automação**.

> **Nota:** a presença de arquivos de configuração não significa que todos os serviços estejam implantados ou que todas as funcionalidades de negócio estejam concluídas.

## Tecnologias e ferramentas

| Camada | Tecnologia | Utilização |
| --- | --- | --- |
| Backend | PHP 8.2+ | Linguagem principal |
| Framework | Laravel 11 | Estrutura da aplicação |
| Banco de dados | PostgreSQL | Persistência de dados |
| Plataforma de dados | Supabase | Integração configurada no ambiente Docker |
| Contêineres | Docker / Docker Compose | Empacotamento e execução |
| Automação | Jenkins | Arquivo `Jenkinsfile` presente no projeto |
| Deploy | Railway | Arquivo `railway.json` presente no projeto |
| Testes | PHPUnit | Dependência de desenvolvimento |

## Arquitetura e organização

O projeto segue a organização do framework Laravel, com separação entre regras de aplicação, configuração e infraestrutura. Alguns arquivos relevantes da raiz:

```text
Zeno/
├── artisan                 # CLI do Laravel
├── composer.json           # Dependências PHP
├── phpunit.xml             # Configuração de testes
├── Dockerfile              # Imagem da aplicação
├── docker-compose.yml      # Orquestração local
├── Jenkinsfile             # Configuração de pipeline
├── railway.json            # Configuração de deploy
├── Procfile                # Comando de inicialização
└── TROUBLESHOOTING.md      # Notas de solução de problemas
```

## Pré-requisitos

Para execução local sem contêineres:

- PHP 8.2 ou superior, com extensões exigidas pelo Laravel;
- Composer;
- acesso a um banco PostgreSQL compatível;
- credenciais e variáveis de ambiente do projeto.

Para execução em contêineres, instale Docker e Docker Compose.

## Instalação local

Clone o projeto e instale as dependências:

```bash
git clone https://github.com/KauaSteter/Zeno.git
cd Zeno
composer install
```

Configure o ambiente **sem versionar credenciais**. Se existir um arquivo `.env.example` na versão utilizada, copie-o para `.env` e preencha as variáveis necessárias. Caso contrário, crie o `.env` conforme a configuração da aplicação.

```bash
php artisan key:generate
```

Após validar a conexão com o banco e conferir as migrations da branch utilizada:

```bash
php artisan migrate
php artisan serve
```

A aplicação normalmente ficará disponível em `http://localhost:8000` quando iniciada com `artisan serve`.

> **Atenção:** execute migrations somente em um banco de desenvolvimento ou em um ambiente autorizado, após verificar os efeitos no esquema e possuir backup adequado.

## Execução com Docker

O repositório contém um `docker-compose.yml` com serviço web na porta **8000** e variáveis de conexão com Supabase/PostgreSQL.

Defina as variáveis exigidas pelo Compose no ambiente local, incluindo:

```dotenv
SUPABASE_HOST=
SUPABASE_USER=
SUPABASE_PASSWORD=
SUPABASE_URL=
SUPABASE_KEY=
```

Depois execute:

```bash
docker compose up --build
```

Acesse `http://localhost:8000`. Não publique arquivos `.env`, chaves, senhas ou dumps com dados reais.

## Testes

O projeto declara **PHPUnit** como dependência de desenvolvimento. Após instalar as dependências e configurar um banco isolado para testes, utilize:

```bash
php artisan test
```

A execução e o resultado dos testes dependem da branch e da configuração local.

## Entrega e implantação

O repositório inclui artefatos de infraestrutura para diferentes fluxos:

- **Dockerfile:** construção da imagem da aplicação;
- **Jenkinsfile:** base para pipeline de automação;
- **railway.json:** configuração relacionada ao Railway;
- **Procfile:** comando de inicialização em plataformas compatíveis.

Antes de publicar em produção, revise variáveis de ambiente, permissões, conexão com o banco, migrações, logs e política de segredos.

## Demonstração

Capturas de tela e link público de demonstração poderão ser adicionados quando uma versão estiver disponível.

<!-- Exemplo: ![Tela principal do Zeno ERP](docs/images/dashboard.png) -->

## Status do projeto

**Em desenvolvimento.** A disponibilidade de módulos e fluxos de negócio deve ser verificada na branch e na versão em uso.

## Autoria e créditos

Repositório mantido em [KauaSteter/Zeno](https://github.com/KauaSteter/Zeno). O identificador do pacote Composer é `arielmpires/zeno-erp`; preserve os créditos dos colaboradores e do projeto original conforme o histórico do repositório.

## Licença

O `composer.json` declara `proprietary`. **Não presuma que o código possui licença de uso, distribuição ou modificação irrestrita.** Consulte os responsáveis pelo projeto antes de reutilizá-lo ou redistribuí-lo.

---

<div align="center">

**Zeno ERP** · Gestão em equilíbrio

[Voltar ao topo](#zeno-erp)

</div>

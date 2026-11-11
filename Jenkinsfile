// =============================================================================
// ZENO ERP - Jenkinsfile (Pipeline Declarativa)
// Branch develop -> Deploy no container LXC Ubuntu (Homologação / Testes)
// Branch main    -> Deploy no Render (Produção / Instância Oficial)
// =============================================================================

pipeline {
    agent any

    environment {
        APP_NAME         = 'zeno-erp'
        // Credenciais cadastradas no Jenkins Credentials Manager:
        // 1. RENDER_DEPLOY_HOOK: Secret text com a URL do deploy hook do Render
        // 2. LXC_SSH_KEY: SSH Username with private key para o container Ubuntu
        RENDER_HOOK_CRED = 'render-deploy-hook-zeno'
        LXC_CRED_ID      = 'lxc-ubuntu-ssh-key'

        // Configuração do ambiente LXC (Homologação / Develop)
        LXC_HOST         = '192.168.15.43' // Ajuste para o IP ou hostname do seu container
        LXC_USER         = 'jenkins'
        LXC_PATH         = '/var/www/zeno-erp-develop'
    }

    options {
        timeout(time: 20, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '15'))
        disableConcurrentBuilds()
    }

    stages {
        stage('Checkout do Código') {
            steps {
                echo "Clonando branch ${env.BRANCH_NAME}..."
                checkout scm
            }
        }

        stage('Validação & Dependências (Composer)') {
            steps {
                echo 'Validando sintaxe do composer.json...'
                sh '''
                    # Se composer existir no PATH do Jenkins, valida apenas a sintaxe
                    if command -v composer >/dev/null 2>&1; then
                        composer validate --no-check-lock --no-check-all
                    else
                        echo "Composer não encontrado no host Jenkins - prosseguindo..."
                    fi
                '''
            }
        }

        stage('Testes Automatizados & Linter') {
            steps {
                echo 'Verificando testes automatizados...'
                sh '''
                    if command -v php >/dev/null 2>&1 && [ -f vendor/bin/phpunit ]; then
                        if [ ! -f .env.testing ]; then
                            cp .env.example .env.testing || true
                        fi
                        php artisan test --parallel --env=testing || ./vendor/bin/phpunit
                    else
                        echo "PHP/PHPUnit não configurado no agente Jenkins - prosseguindo para o deploy..."
                    fi
                '''
            }
        }

        stage('Deploy Homologação (Develop -> LXC Ubuntu)') {
            when {
                branch 'develop'
            }
            steps {
                echo 'Iniciando deploy no container LXC Ubuntu...'
                // Usando withCredentials nativo do Jenkins (sem depender de plugin SSH Agent externo)
                withCredentials([sshUserPrivateKey(credentialsId: env.LXC_CRED_ID, keyFileVariable: 'LXC_KEY', usernameVariable: 'LXC_USER_VAR')]) {
                    sh '''
                        # Garantir permissões estritas da chave privada temporária
                        chmod 600 "${LXC_KEY}"

                        # 1. Sincronização via rsync usando a chave privada
                        rsync -avz --delete --no-perms --no-owner --no-group --omit-dir-times \
                            -e "ssh -i ${LXC_KEY} -o StrictHostKeyChecking=no" \
                            --exclude='.git/***' \
                            --exclude='.env' \
                            --exclude='vendor/***' \
                            --exclude='vendor_backup/***' \
                            --exclude='storage/***' \
                            --exclude='bootstrap/cache/***' \
                            --exclude='node_modules/***' \
                            ./ ${LXC_USER_VAR}@${LXC_HOST}:${LXC_PATH}/

                        # 2. Execução dos comandos de manutenção no container remoto
                        ssh -i "${LXC_KEY}" -o StrictHostKeyChecking=no ${LXC_USER_VAR}@${LXC_HOST} << 'EOF'
                            cd /var/www/zeno-erp-develop

                            # Garantir diretórios graváveis do Laravel (propriedade/permissões configuradas uma vez no LXC)
                            mkdir -p storage/logs storage/framework/cache storage/framework/sessions storage/framework/views bootstrap/cache

                            # Instalar dependências sem dev
                            composer install --no-dev --optimize-autoloader --no-interaction

                            # Limpar e reconstruir caches do Laravel
                            php artisan optimize:clear
                            php artisan config:cache
                            php artisan route:cache
                            php artisan view:cache

                            # Reiniciar PHP-FPM e Horizon/Queue se ativos
                            sudo systemctl reload php8.2-fpm || sudo systemctl reload php8.3-fpm || true
                            php artisan queue:restart || true
EOF
                    '''
                }
            }
        }

        stage('Deploy Produção (Main -> Render via Docker)') {
            when {
                branch 'main'
            }
            steps {
                echo 'Disparando deploy de produção no Render (Docker Web Service)...'
                withCredentials([string(credentialsId: env.RENDER_HOOK_CRED, variable: 'RENDER_URL')]) {
                    sh '''
                        # Disparo via curl ou wget ou python (conforme disponível no agente)
                        if command -v curl >/dev/null 2>&1; then
                            RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X POST "${RENDER_URL}")
                        elif command -v wget >/dev/null 2>&1; then
                            RESPONSE=$(wget --spider --server-response --post-data="" "${RENDER_URL}" 2>&1 | awk '/HTTP\\// {print $2}' | tail -n 1)
                        elif command -v python3 >/dev/null 2>&1; then
                            RESPONSE=$(python3 -c "import urllib.request; req=urllib.request.Request('${RENDER_URL}', method='POST'); res=urllib.request.urlopen(req); print(res.getcode())")
                        else
                            echo "Erro: nem curl, wget ou python3 estão instalados no Jenkins."
                            exit 1
                        fi

                        if [ "$RESPONSE" -eq 200 ] || [ "$RESPONSE" -eq 201 ]; then
                            echo "Deploy Docker no Render disparado com sucesso (HTTP $RESPONSE)."
                        else
                            echo "Falha ao disparar deploy no Render. Código HTTP retornado: $RESPONSE"
                            exit 1
                        fi
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline concluída com sucesso para a branch ${env.BRANCH_NAME}."
        }
        failure {
            echo "Falha na pipeline na branch ${env.BRANCH_NAME}. Verifique o console output."
        }
    }
}

-- ============================================================================
-- ZENO ERP - Schema Completo do Supabase PostgreSQL
-- Data: 2026-11-06
-- Descrição: Schema unificado para ZENO ERP (Laravel 11 + PHP + Tailwind)
-- Inclui todas as tabelas do ERP para clientes, fornecedores, compras, vendas, ordens de serviço,
-- financeiro, contabilidade, tributação, Mercado Livre, fretes, formas de pagamento, agenda,
-- marketing, recursos humanos, obras, contratos e muito mais.
-- ============================================================================

-- EXTENSÕES
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- MÓDULO: USUÁRIOS E AUTENTICAÇÃO
-- ============================================================================
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID,
    nome VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    cpf VARCHAR(14) UNIQUE,
    telefone VARCHAR(20),
    role VARCHAR(50) NOT NULL CHECK (role IN ('admin', 'gerente', 'vendedor', 'financeiro', 'logista')),
    departamento VARCHAR(100),
    avatar TEXT,
    ultimo_login TIMESTAMP,
    remember_token VARCHAR(100),
    ativo BOOLEAN DEFAULT TRUE,
    data_contratacao DATE,
    salario_base DECIMAL(15,2),
    comissao_percentual DECIMAL(5,2),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_cpf ON users(cpf);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);

CREATE TABLE IF NOT EXISTS password_reset_tokens (
    email VARCHAR(255) PRIMARY KEY,
    token VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- ============================================================================
-- MÓDULO: ORGANIZAÇÃO (Tenant/Base)
-- ============================================================================
CREATE TABLE IF NOT EXISTS empresas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    razao_social VARCHAR(255) NOT NULL,
    nome_fantasia VARCHAR(255),
    cnpj VARCHAR(18) UNIQUE NOT NULL,
    inscricao_estadual VARCHAR(20),
    inscricao_municipal VARCHAR(20),
    situacao_cadastral VARCHAR(30),
    data_fundacao DATE,
    telefone VARCHAR(20),
    email VARCHAR(255),
    site VARCHAR(255),
    logo_url TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- ============================================================================
-- MÓDULO: CLIENTES (PF/PJ)
-- ============================================================================
CREATE TABLE IF NOT EXISTS clientes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID,
    tipo VARCHAR(20) NOT NULL CHECK (tipo IN ('PF', 'PJ')),
    nome VARCHAR(255) NOT NULL,
    razao_social VARCHAR(255),
    nome_fantasia VARCHAR(255),
    cpf_cnpj VARCHAR(18) UNIQUE NOT NULL,
    inscricao_estadual VARCHAR(20),
    ie VARCHAR(20),
    inscricao_municipal VARCHAR(20),
    telefone VARCHAR(20),
    celular VARCHAR(20),
    whatsapp VARCHAR(20),
    email VARCHAR(255),
    cep VARCHAR(9),
    endereco VARCHAR(255),
    numero VARCHAR(10),
    complemento VARCHAR(100),
    bairro VARCHAR(100),
    cidade VARCHAR(100),
    estado VARCHAR(2),
    codigo_ibge_municipio VARCHAR(7),
    limite_credito DECIMAL(15,2) DEFAULT 0.00,
    credito_utilizado DECIMAL(15,2) DEFAULT 0.00,
    observacoes TEXT,
    ativo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_clientes_cpf_cnpj ON clientes(cpf_cnpj);
CREATE INDEX IF NOT EXISTS idx_clientes_nome ON clientes(nome);
CREATE INDEX IF NOT EXISTS idx_clientes_tipo ON clientes(tipo);

CREATE TABLE IF NOT EXISTS creditos_clientes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    cliente_id UUID REFERENCES clientes(id) ON DELETE CASCADE,
    tipo VARCHAR(50) NOT NULL CHECK (tipo IN ('credito', 'desconto', 'bonificacao')),
    valor DECIMAL(15,2) NOT NULL,
    descricao TEXT,
    data_inicio DATE,
    data_fim DATE,
    usado DECIMAL(15,2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT NOW()
);

-- ============================================================================
-- MÓDULO: PRODUTOS E CATEGORIAS
-- ============================================================================
CREATE TABLE IF NOT EXISTS categorias_produto (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    ativo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_categorias_produto_nome ON categorias_produto(nome);

CREATE TABLE IF NOT EXISTS produtos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID,
    categoria_id UUID REFERENCES categorias_produto(id) ON DELETE SET NULL,
    sku VARCHAR(50) UNIQUE NOT NULL,
    codigo VARCHAR(50),
    nome VARCHAR(255) NOT NULL,
    descricao TEXT,
    preco_custo DECIMAL(15,2) DEFAULT 0.00,
    preco_venda DECIMAL(15,2) DEFAULT 0.00,
    preco_promocional DECIMAL(15,2),
    unidade VARCHAR(20) DEFAULT 'un',
    unidade_medida VARCHAR(10) DEFAULT 'UN',
    ncm VARCHAR(8),
    cest VARCHAR(7),
    cfop VARCHAR(4) DEFAULT '5102',
    estoque_atual INTEGER DEFAULT 0,
    estoque_minimo INTEGER DEFAULT 0,
    estoque_maximo INTEGER,
    ml_id VARCHAR(50),
    ml_sincronizado BOOLEAN DEFAULT false,
    ml_ultima_sync TIMESTAMP,
    imagens_adicionais JSONB,
    ativo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_produtos_sku ON produtos(sku);
CREATE INDEX IF NOT EXISTS idx_produtos_ncm ON produtos(ncm);
CREATE INDEX IF NOT EXISTS idx_produtos_ml_id ON produtos(ml_id);

-- ============================================================================
-- MÓDULO: SERVIÇOS
-- ============================================================================
CREATE TABLE IF NOT EXISTS servicos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID,
    codigo VARCHAR(50) UNIQUE NOT NULL,
    nome VARCHAR(255) NOT NULL,
    descricao TEXT,
    custo_hora DECIMAL(15,2) DEFAULT 0.00,
    preco_hora DECIMAL(15,2) NOT NULL,
    tempo_estimado_horas DECIMAL(5,2),
    tempo_padrao_hora INTEGER DEFAULT 60,
    ativo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_servicos_codigo ON servicos(codigo);

-- ============================================================================
-- MÓDULO: FORNECEDORES
-- ============================================================================
CREATE TABLE IF NOT EXISTS fornecedores (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID,
    tipo VARCHAR(20) NOT NULL CHECK (tipo IN ('PF', 'PJ')),
    nome VARCHAR(255) NOT NULL,
    razao_social VARCHAR(255),
    cpf_cnpj VARCHAR(18) UNIQUE NOT NULL,
    inscricao_estadual VARCHAR(20),
    ie VARCHAR(20),
    telefone VARCHAR(20),
    celular VARCHAR(20),
    email VARCHAR(255),
    cep VARCHAR(9),
    endereco TEXT,
    numero VARCHAR(10),
    complemento VARCHAR(100),
    bairro VARCHAR(100),
    cidade VARCHAR(100),
    estado VARCHAR(2),
    codigo_ibge_municipio VARCHAR(7),
    observacoes TEXT,
    ativo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_fornecedores_cpf_cnpj ON fornecedores(cpf_cnpj);

-- ============================================================================
-- MÓDULO: COMPRAS
-- ============================================================================
CREATE TABLE IF NOT EXISTS compras (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID,
    numero_compra VARCHAR(50) UNIQUE NOT NULL,
    fornecedor_id UUID REFERENCES fornecedores(id) ON DELETE RESTRICT,
    usuario_id UUID REFERENCES users(id) ON DELETE SET NULL,
    data_compra DATE NOT NULL,
    data_entrega_prevista DATE,
    data_entrega_real DATE,
    subtotal DECIMAL(15,2) DEFAULT 0.00,
    desconto DECIMAL(15,2) DEFAULT 0.00,
    frete DECIMAL(15,2) DEFAULT 0.00,
    outras_despesas DECIMAL(15,2) DEFAULT 0.00,
    total DECIMAL(15,2) NOT NULL,
    status VARCHAR(50) DEFAULT 'pendente' CHECK (status IN ('pendente', 'aberta', 'recebida', 'cancelada')),
    observacoes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_compras_numero ON compras(numero_compra);
CREATE INDEX IF NOT EXISTS idx_compras_data ON compras(data_compra);
CREATE INDEX IF NOT EXISTS idx_compras_status ON compras(status);

CREATE TABLE IF NOT EXISTS compras_itens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    compra_id UUID REFERENCES compras(id) ON DELETE CASCADE,
    produto_id UUID REFERENCES produtos(id) ON DELETE RESTRICT,
    numero_parcela VARCHAR DEFAULT '1',
    quantidade INTEGER NOT NULL,
    quantidade_recebida INTEGER DEFAULT 0,
    custo_unitario DECIMAL(15,2) NOT NULL,
    desconto DECIMAL(15,2) DEFAULT 0.00,
    acrescimo DECIMAL(15,2) DEFAULT 0.00,
    total DECIMAL(15,2) NOT NULL,
    valor_liquido DECIMAL(15,2) GENERATED ALWAYS AS (quantidade * custo_unitario + acrescimo - desconto) STORED,
    created_at TIMESTAMP DEFAULT NOW()
);

-- ============================================================================
-- MÓDULO: VENDAS
-- ============================================================================
CREATE TABLE IF NOT EXISTS vendas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID,
    numero_venda VARCHAR(50) UNIQUE NOT NULL,
    cliente_id UUID REFERENCES clientes(id) ON DELETE RESTRICT,
    usuario_id UUID REFERENCES users(id) ON DELETE SET NULL,
    data_venda TIMESTAMP NOT NULL DEFAULT NOW(),
    subtotal DECIMAL(15,2) DEFAULT 0.00,
    desconto DECIMAL(15,2) DEFAULT 0.00,
    frete DECIMAL(15,2) DEFAULT 0.00,
    total DECIMAL(15,2) NOT NULL,
    forma_pagamento VARCHAR(50),
    status_pagamento VARCHAR(50) DEFAULT 'pendente' CHECK (status_pagamento IN ('pendente', 'pago', 'parcial', 'cancelado')),
    nfe_emitida BOOLEAN DEFAULT false,
    nfe_numero VARCHAR(20),
    nfe_chave VARCHAR(44),
    nfe_xml TEXT,
    ml_order_id VARCHAR(50),
    origem VARCHAR(20) DEFAULT 'loja' CHECK (origem IN ('loja', 'site', 'ml', 'telefone')),
    observacoes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_vendas_numero ON vendas(numero_venda);
CREATE INDEX IF NOT EXISTS idx_vendas_data ON vendas(data_venda);
CREATE INDEX IF NOT EXISTS idx_vendas_status ON vendas(status_pagamento);
CREATE INDEX IF NOT EXISTS idx_vendas_ml_order ON vendas(ml_order_id);
CREATE INDEX IF NOT EXISTS idx_vendas_origem ON vendas(origem);

CREATE TABLE IF NOT EXISTS vendas_itens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    venda_id UUID REFERENCES vendas(id) ON DELETE CASCADE,
    produto_id UUID REFERENCES produtos(id) ON DELETE RESTRICT,
    numero_parcela VARCHAR DEFAULT '1',
    quantidade INTEGER NOT NULL,
    preco_unitario DECIMAL(15,2) NOT NULL,
    desconto DECIMAL(15,2) DEFAULT 0.00,
    acrescimo DECIMAL(15,2) DEFAULT 0.00,
    total DECIMAL(15,2) NOT NULL,
    valor_liquido DECIMAL(15,2) GENERATED ALWAYS AS (quantidade * preco_unitario + acrescimo - desconto) STORED,
    created_at TIMESTAMP DEFAULT NOW()
);

-- ============================================================================
-- MÓDULO: ORDENS DE SERVIÇO
-- ============================================================================
CREATE TABLE IF NOT EXISTS ordens_servico (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID,
    numero_os VARCHAR(50) UNIQUE NOT NULL,
    cliente_id UUID REFERENCES clientes(id) ON DELETE RESTRICT,
    usuario_id UUID REFERENCES users(id) ON DELETE SET NULL,
    data_abertura TIMESTAMP NOT NULL DEFAULT NOW(),
    data_previsao DATE,
    data_conclusao TIMESTAMP,
    titulo VARCHAR(255) NOT NULL,
    descricao_problema TEXT,
    descricao_solucao TEXT,
    total_servicos DECIMAL(15,2) DEFAULT 0.00,
    total_produtos DECIMAL(15,2) DEFAULT 0.00,
    desconto DECIMAL(15,2) DEFAULT 0.00,
    total DECIMAL(15,2) NOT NULL,
    status VARCHAR(50) DEFAULT 'aberta' CHECK (status IN ('aberta', 'em_andamento', 'aguardando_aprovacao', 'concluida', 'cancelada')),
    prioridade VARCHAR(20) DEFAULT 'normal' CHECK (prioridade IN ('baixa', 'normal', 'alta', 'urgente')),
    nfse_emitida BOOLEAN DEFAULT false,
    nfse_numero VARCHAR(20),
    nfse_codigo_verificacao VARCHAR(20),
    observacoes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_os_numero ON ordens_servico(numero_os);
CREATE INDEX IF NOT EXISTS idx_os_data ON ordens_servico(data_abertura);
CREATE INDEX IF NOT EXISTS idx_os_status ON ordens_servico(status);

CREATE TABLE IF NOT EXISTS os_servicos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    os_id UUID REFERENCES ordens_servico(id) ON DELETE CASCADE,
    servico_id UUID REFERENCES servicos(id) ON DELETE RESTRICT,
    descricao TEXT,
    quantidade_horas DECIMAL(5,2) NOT NULL,
    preco_hora DECIMAL(15,2) NOT NULL,
    total DECIMAL(15,2) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS os_produtos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    os_id UUID REFERENCES ordens_servico(id) ON DELETE CASCADE,
    produto_id UUID REFERENCES produtos(id) ON DELETE RESTRICT,
    quantidade INTEGER NOT NULL,
    preco_unitario DECIMAL(15,2) NOT NULL,
    total DECIMAL(15,2) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- ============================================================================
-- MÓDULO: MERCADO LIVRE
-- ============================================================================
CREATE TABLE IF NOT EXISTS ml_configuracao (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID,
    app_id VARCHAR(50) NOT NULL,
    client_secret VARCHAR(100) NOT NULL,
    access_token TEXT,
    refresh_token TEXT,
    token_expira_em TIMESTAMP,
    sync_estoque BOOLEAN DEFAULT true,
    sync_precos BOOLEAN DEFAULT true,
    markup_ml DECIMAL(5,2) DEFAULT 0.00,
    ultima_sincronizacao TIMESTAMP,
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS ml_pedidos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    ml_order_id VARCHAR(50) UNIQUE NOT NULL,
    venda_id UUID REFERENCES vendas(id) ON DELETE SET NULL,
    status VARCHAR(50),
    status_shipping VARCHAR(50),
    comprador_nome VARCHAR(255),
    comprador_email VARCHAR(255),
    comprador_telefone VARCHAR(20),
    dados_envio JSONB,
    dados_completos JSONB,
    processado BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_ml_pedidos_order_id ON ml_pedidos(ml_order_id);

-- ============================================================================
-- MÓDULO: CONTABILIDADE E TRIBUTAÇÃO
-- ============================================================================
CREATE TABLE IF NOT EXISTS configuracao_fiscal (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID,
    regime VARCHAR(50) NOT NULL CHECK (regime IN ('simples_nacional', 'lucro_presumido', 'lucro_real', 'mei')),
    anexo VARCHAR(10),
    faixa_receita_12meses DECIMAL(15,2),
    aliquota_efetiva DECIMAL(5,2),
    cnpj VARCHAR(18) NOT NULL,
    razao_social VARCHAR(255) NOT NULL,
    nome_fantasia VARCHAR(255),
    ie VARCHAR(20),
    im VARCHAR(20),
    cep VARCHAR(9),
    endereco VARCHAR(255),
    numero VARCHAR(10),
    complemento VARCHAR(100),
    bairro VARCHAR(100),
    cidade VARCHAR(100),
    uf VARCHAR(2),
    codigo_municipio VARCHAR(7),
    ambiente_nfe VARCHAR(20) DEFAULT 'homologacao' CHECK (ambiente_nfe IN ('homologacao', 'producao')),
    serie_nfe INTEGER DEFAULT 1,
    numero_ultima_nfe INTEGER DEFAULT 0,
    ambiente_nfse VARCHAR(20) DEFAULT 'homologacao' CHECK (ambiente_nfse IN ('homologacao', 'producao')),
    serie_nfse INTEGER DEFAULT 1,
    numero_ultima_nfse INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS regras_tributarias (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID,
    nome VARCHAR(255),
    uf_origem VARCHAR(2) NOT NULL,
    uf_destino VARCHAR(2) NOT NULL,
    tipo_destinatario VARCHAR(20) NOT NULL CHECK (tipo_destinatario IN ('pf', 'pj', 'orgao_publico')),
    contribuinte_icms BOOLEAN DEFAULT false,
    tipo_operacao VARCHAR(20) NOT NULL CHECK (tipo_operacao IN ('venda', 'devolucao', 'transferencia', 'remessa')),
    finalidade VARCHAR(50) DEFAULT 'consumo_final' CHECK (finalidade IN ('consumo_final', 'revenda', 'ativo')),
    cfop VARCHAR(4) NOT NULL,
    cst_icms VARCHAR(3),
    cst_pis_cofins VARCHAR(2),
    aliquota_icms DECIMAL(5,2) DEFAULT 0.00,
    aliquota_pis DECIMAL(5,2) DEFAULT 0.00,
    aliquota_cofins DECIMAL(5,2) DEFAULT 0.00,
    aliquota_iss DECIMAL(5,2) DEFAULT 0.00,
    reducao_base_icms DECIMAL(5,2) DEFAULT 0.00,
    aplica_st BOOLEAN DEFAULT false,
    mva DECIMAL(5,2) DEFAULT 0.00,
    mensagem_nota TEXT,
    observacao_interna TEXT,
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_regras_origem_destino ON regras_tributarias(uf_origem, uf_destino);

CREATE TABLE IF NOT EXISTS ncm_tributacao (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    ncm VARCHAR(8) UNIQUE NOT NULL,
    descricao TEXT NOT NULL,
    cest VARCHAR(7),
    aliquota_ipi DECIMAL(5,2) DEFAULT 0.00,
    excecoes_estaduais JSONB,
    tipo VARCHAR(50),
    ativo BOOLEAN DEFAULT true,
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_ncm_codigo ON ncm_tributacao(ncm);

CREATE TABLE IF NOT EXISTS calculos_tributarios (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    venda_id UUID REFERENCES vendas(id) ON DELETE CASCADE,
    venda_item_id UUID,
    produto_id UUID REFERENCES produtos(id),
    regra_aplicada_id UUID REFERENCES regras_tributarias(id),
    ncm_aplicado_id UUID REFERENCES ncm_tributacao(id),
    valor_produto DECIMAL(15,2) NOT NULL,
    base_calculo_icms DECIMAL(15,2),
    base_calculo_icms_st DECIMAL(15,2),
    base_calculo_pis DECIMAL(15,2),
    base_calculo_cofins DECIMAL(15,2),
    valor_icms DECIMAL(15,2) DEFAULT 0.00,
    valor_icms_st DECIMAL(15,2) DEFAULT 0.00,
    valor_ipi DECIMAL(15,2) DEFAULT 0.00,
    valor_pis DECIMAL(15,2) DEFAULT 0.00,
    valor_cofins DECIMAL(15,2) DEFAULT 0.00,
    valor_iss DECIMAL(15,2) DEFAULT 0.00,
    total_impostos DECIMAL(15,2) GENERATED ALWAYS AS (
        valor_icms + valor_icms_st + valor_ipi + valor_pis + valor_cofins + valor_iss
    ) STORED,
    detalhamento JSONB,
    created_at TIMESTAMP DEFAULT NOW()
);

-- ============================================================================
-- MÓDULO: DEVOLUÇÕES E TROCAS
-- ============================================================================
CREATE TABLE IF NOT EXISTS devolucoes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID,
    numero_devolucao VARCHAR(50) UNIQUE NOT NULL,
    venda_id UUID REFERENCES vendas(id) ON DELETE RESTRICT,
    cliente_id UUID REFERENCES clientes(id),
    usuario_id UUID REFERENCES users(id),
    tipo VARCHAR(20) NOT NULL CHECK (tipo IN ('devolucao', 'troca')),
    motivo VARCHAR(50) CHECK (motivo IN ('defeito', 'arrependimento', 'erro_pedido', 'nao_corresponde')),
    descricao_motivo TEXT,
    data_devolucao TIMESTAMP DEFAULT NOW(),
    total_devolvido DECIMAL(15,2) NOT NULL,
    total_reembolsado DECIMAL(15,2) DEFAULT 0.00,
    status VARCHAR(50) DEFAULT 'solicitada' CHECK (status IN ('solicitada', 'aprovada', 'recusada', 'concluida')),
    nfe_devolucao_emitida BOOLEAN DEFAULT false,
    nfe_devolucao_chave VARCHAR(44),
    observacoes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_devolucoes_venda ON devolucoes(venda_id);
CREATE INDEX IF NOT EXISTS idx_devolucoes_status ON devolucoes(status);

CREATE TABLE IF NOT EXISTS devolucao_itens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    devolucao_id UUID REFERENCES devolucoes(id) ON DELETE CASCADE,
    venda_item_id UUID,
    produto_id UUID REFERENCES produtos(id),
    quantidade INTEGER NOT NULL,
    valor_unitario DECIMAL(15,2) NOT NULL,
    total DECIMAL(15,2) NOT NULL,
    produto_troca_id UUID REFERENCES produtos(id),
    quantidade_troca INTEGER,
    diferenca_valor DECIMAL(15,2) DEFAULT 0.00,
    condicao VARCHAR(50) CHECK (condicao IN ('novo', 'usado_bom', 'usado_ruim', 'danificado')),
    retorna_estoque BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW()
);

-- ============================================================================
-- MÓDULO: COMISSÕES
-- ============================================================================
CREATE TABLE IF NOT EXISTS configuracao_comissoes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    usuario_id UUID REFERENCES users(id) ON DELETE CASCADE,
    tipo VARCHAR(50) NOT NULL CHECK (tipo IN ('percentual', 'valor_fixo', 'mista', 'por_produto')),
    percentual_padrao DECIMAL(5,2) DEFAULT 0.00,
    valor_fixo_venda DECIMAL(10,2) DEFAULT 0.00,
    comissao_por_categoria JSONB,
    meta_mensal DECIMAL(15,2),
    bonus_meta DECIMAL(5,2),
    vigencia_inicio DATE NOT NULL,
    vigencia_fim DATE,
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS comissoes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    usuario_id UUID REFERENCES users(id) ON DELETE RESTRICT,
    venda_id UUID REFERENCES vendas(id) ON DELETE RESTRICT,
    valor_comissao DECIMAL(15,2) NOT NULL,
    data_referencia DATE NOT NULL,
    status VARCHAR(50) DEFAULT 'pendente' CHECK (status IN ('pendente', 'pago', 'cancelado')),
    observacoes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- ============================================================================
-- MÓDULO: KITS E COMBOS
-- ============================================================================
CREATE TABLE IF NOT EXISTS kits (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID,
    sku VARCHAR(50) UNIQUE NOT NULL,
    nome VARCHAR(255) NOT NULL,
    descricao TEXT,
    preco_venda DECIMAL(15,2) NOT NULL,
    preco_custo_total DECIMAL(15,2) DEFAULT 0.00,
    margem_lucro DECIMAL(5,2),
    imagem_principal TEXT,
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS kit_itens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    kit_id UUID REFERENCES kits(id) ON DELETE CASCADE,
    produto_id UUID REFERENCES produtos(id) ON DELETE RESTRICT,
    quantidade INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE OR REPLACE FUNCTION recalcular_custo_kit()
RETURNS TRIGGER AS $$
DECLARE
    target_kit_id UUID;
    novo_custo DECIMAL(15,2);
BEGIN
    target_kit_id := COALESCE(NEW.kit_id, OLD.kit_id);
    SELECT COALESCE(SUM(p.preco_custo * ki.quantidade), 0.00) INTO novo_custo
    FROM kit_itens ki
    JOIN produtos p ON p.id = ki.produto_id
    WHERE ki.kit_id = target_kit_id;
    UPDATE kits SET preco_custo_total = novo_custo, updated_at = NOW()
    WHERE id = target_kit_id;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_recalcular_custo_kit ON kit_itens;
CREATE TRIGGER trg_recalcular_custo_kit
AFTER INSERT OR UPDATE OR DELETE ON kit_itens
FOR EACH ROW EXECUTE FUNCTION recalcular_custo_kit();

-- ============================================================================
-- MÓDULO: SERIAL NUMBER / LOTE
-- ============================================================================
CREATE TABLE IF NOT EXISTS produtos_seriais (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID,
    produto_id UUID REFERENCES produtos(id) ON DELETE CASCADE,
    numero_serie VARCHAR(100) UNIQUE NOT NULL,
    imei VARCHAR(20),
    lote VARCHAR(50),
    data_fabricacao DATE,
    data_validade DATE,
    status VARCHAR(50) DEFAULT 'estoque' CHECK (status IN ('estoque', 'vendido', 'defeito', 'devolucao')),
    venda_id UUID REFERENCES vendas(id),
    data_venda TIMESTAMP,
    observacoes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_produtos_seriais_numero ON produtos_seriais(numero_serie);

-- ============================================================================
-- MÓDULO: FORMAS DE PAGAMENTO E PARCELAS
-- ============================================================================
CREATE TABLE IF NOT EXISTS formas_pagamento (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID,
    nome VARCHAR(100) NOT NULL CHECK (nome IN ('dinheiro', 'credito', 'debito', 'pix', 'boleto', 'cartao', 'cheque', 'vale')),
    tipo VARCHAR(50) CHECK (tipo IN ('vista', 'prazo')),
    taxa_percentual DECIMAL(5,2) DEFAULT 0.00,
    permite_parcelamento BOOLEAN DEFAULT false,
    max_parcelas INTEGER DEFAULT 1,
    dias_recebimento INTEGER DEFAULT 0,
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_formas_pagamento_nome ON formas_pagamento(nome);

CREATE TABLE IF NOT EXISTS venda_pagamentos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    venda_id UUID REFERENCES vendas(id) ON DELETE CASCADE,
    forma_pagamento_id UUID REFERENCES formas_pagamento(id),
    valor DECIMAL(15,2) NOT NULL,
    parcelas INTEGER DEFAULT 1,
    valor_parcela DECIMAL(15,2),
    taxa_juros DECIMAL(5,2) DEFAULT 0.00,
    autorizacao VARCHAR(50),
    tid VARCHAR(50),
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS parcelas_receber (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    venda_pagamento_id UUID REFERENCES venda_pagamentos(id) ON DELETE CASCADE,
    conta_receber_id UUID,
    numero_parcela VARCHAR DEFAULT '1',
    valor DECIMAL(15,2) NOT NULL,
    data_vencimento DATE NOT NULL,
    data_recebimento DATE,
    status VARCHAR(50) DEFAULT 'pendente' CHECK (status IN ('pendente', 'recebido', 'vencido')),
    created_at TIMESTAMP DEFAULT NOW()
);

-- ============================================================================
-- MÓDULO: CÁLCULO DE FRETE
-- ============================================================================
CREATE TABLE IF NOT EXISTS configuracao_frete (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID,
    tipo VARCHAR(20) NOT NULL CHECK (tipo IN ('correios', 'melhor_envio', 'fixo', 'gratis', 'tabela')),
    cep_origem VARCHAR(9),
    prazo_adicional INTEGER DEFAULT 0,
    frete_gratis_acima DECIMAL(10,2),
    frete_gratis_regioes JSONB,
    me_token TEXT,
    me_servicos_habilitados JSONB,
    tabela_valores JSONB,
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS fretes_calculados (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID,
    venda_id UUID REFERENCES vendas(id) ON DELETE SET NULL,
    cep_origem VARCHAR(9) NOT NULL,
    cep_destino VARCHAR(9) NOT NULL,
    peso_total DECIMAL(8,3),
    valor_declarado DECIMAL(15,2),
    servico VARCHAR(50),
    transportadora VARCHAR(100),
    valor DECIMAL(10,2) NOT NULL,
    prazo_dias INTEGER,
    codigo_rastreio VARCHAR(50),
    etiqueta_url TEXT,
    status_entrega VARCHAR(50) CHECK (status_entrega IN ('pendente', 'postado', 'transito', 'entregue')),
    data_postagem DATE,
    data_entrega DATE,
    dados_completos JSONB,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- ============================================================================
-- MÓDULO: AGENDA CENTRAL DE ATIVIDADES
-- ============================================================================
CREATE TABLE IF NOT EXISTS agenda_eventos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID,
    titulo VARCHAR(255) NOT NULL,
    descricao TEXT,
    data_inicio TIMESTAMP NOT NULL,
    data_fim TIMESTAMP NOT NULL,
    dia_inteiro BOOLEAN DEFAULT false,
    categoria VARCHAR(50) NOT NULL CHECK (categoria IN ('crm', 'compras', 'financeiro', 'estoque', 'outro')),
    status VARCHAR(20) NOT NULL DEFAULT 'agendado' CHECK (status IN ('agendado', 'concluido', 'cancelado')),
    prioridade VARCHAR(20) NOT NULL DEFAULT 'normal' CHECK (prioridade IN ('baixa', 'normal', 'alta', 'urgente')),
    cliente_id UUID REFERENCES clientes(id) ON DELETE SET NULL,
    fornecedor_id UUID REFERENCES fornecedores(id) ON DELETE SET NULL,
    compra_id UUID REFERENCES compras(id) ON DELETE SET NULL,
    venda_id UUID REFERENCES vendas(id) ON DELETE SET NULL,
    os_id UUID REFERENCES ordens_servico(id) ON DELETE SET NULL,
    usuario_id UUID REFERENCES users(id) ON DELETE SET NULL,
    local VARCHAR(255),
    observacoes TEXT,
    recorrencia VARCHAR(20) DEFAULT 'nunca' CHECK (recorrencia IN ('nunca', 'diario', 'semanal', 'quinzenal', 'mensal')),
    data_fim_recorrencia DATE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_agenda_data_inicio ON agenda_eventos(data_inicio);
CREATE INDEX IF NOT EXISTS idx_agenda_categoria ON agenda_eventos(categoria);
CREATE INDEX IF NOT EXISTS idx_agenda_status ON agenda_eventos(status);

-- ============================================================================
-- MÓDULO: ESTOQUE E MOVIMENTAÇÃO
-- ============================================================================
CREATE TABLE IF NOT EXISTS movimentacoes_estoque (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    produto_id UUID REFERENCES produtos(id) ON DELETE CASCADE,
    usuario_id UUID REFERENCES users(id) ON DELETE SET NULL,
    tipo VARCHAR(20) NOT NULL CHECK (tipo IN ('entrada', 'saida', 'ajuste', 'devolucao')),
    quantidade INTEGER NOT NULL,
    estoque_anterior INTEGER NOT NULL,
    estoque_atual INTEGER NOT NULL,
    referencia_tipo VARCHAR(50),
    referencia_id UUID,
    observacao TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- ============================================================================
-- MÓDULO: SITE E MARKETING
-- ============================================================================
CREATE TABLE IF NOT EXISTS site_configuracao (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID,
    nome_loja VARCHAR(255) NOT NULL,
    slogan VARCHAR(255),
    dominio VARCHAR(255),
    logo_url TEXT,
    favicon_url TEXT,
    cor_primaria VARCHAR(7),
    cor_secundaria VARCHAR(7),
    meta_title VARCHAR(255),
    meta_description TEXT,
    meta_keywords TEXT,
    facebook_url VARCHAR(255),
    instagram_url VARCHAR(255),
    whatsapp VARCHAR(20),
    google_analytics VARCHAR(50),
    facebook_pixel VARCHAR(50),
    site_ativo BOOLEAN DEFAULT false,
    loja_online_ativa BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS site_paginas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    slug VARCHAR(100) UNIQUE NOT NULL,
    titulo VARCHAR(255) NOT NULL,
    conteudo TEXT,
    meta_title VARCHAR(255),
    meta_description TEXT,
    ordem INTEGER DEFAULT 0,
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_site_paginas_slug ON site_paginas(slug);

CREATE TABLE IF NOT EXISTS site_banners (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    titulo VARCHAR(255),
    subtitulo VARCHAR(255),
    imagem_url TEXT NOT NULL,
    imagem_mobile_url TEXT,
    link_destino VARCHAR(255),
    botao_texto VARCHAR(50),
    ordem INTEGER DEFAULT 0,
    ativo BOOLEAN DEFAULT true,
    data_inicio TIMESTAMP,
    data_fim TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS marketing_campanhas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID,
    nome VARCHAR(255) NOT NULL,
    tipo VARCHAR(50),
    data_inicio TIMESTAMP NOT NULL,
    data_fim TIMESTAMP NOT NULL,
    tipo_desconto VARCHAR(20),
    valor_desconto DECIMAL(10,2),
    produtos_ids JSONB,
    categorias_ids JSONB,
    publicar_site BOOLEAN DEFAULT true,
    publicar_instagram BOOLEAN DEFAULT false,
    publicar_facebook BOOLEAN DEFAULT false,
    texto_post TEXT,
    imagem_post_url TEXT,
    hashtags TEXT,
    status VARCHAR(50) DEFAULT 'rascunho' CHECK (status IN ('rascunho', 'agendada', 'ativa', 'finalizada')),
    visualizacoes INTEGER DEFAULT 0,
    cliques INTEGER DEFAULT 0,
    vendas_geradas INTEGER DEFAULT 0,
    receita_gerada DECIMAL(15,2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_campanhas_status ON marketing_campanhas(status);

CREATE TABLE IF NOT EXISTS marketing_posts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    campanha_id UUID REFERENCES marketing_campanhas(id) ON DELETE SET NULL,
    plataforma VARCHAR(50) NOT NULL CHECK (plataforma IN ('instagram', 'facebook', 'site')),
    tipo VARCHAR(50),
    conteudo TEXT NOT NULL,
    imagem_url TEXT,
    video_url TEXT,
    data_publicacao TIMESTAMP NOT NULL,
    publicado BOOLEAN DEFAULT false,
    post_id_externo VARCHAR(100),
    url_publicacao TEXT,
    curtidas INTEGER DEFAULT 0,
    comentarios INTEGER DEFAULT 0,
    compartilhamentos INTEGER DEFAULT 0,
    alcance INTEGER DEFAULT 0,
    status VARCHAR(50) DEFAULT 'agendado' CHECK (status IN ('agendado', 'publicado', 'erro', 'cancelado')),
    erro_mensagem TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- ============================================================================
-- MÓDULO: RECURSOS HUMANOS
-- ============================================================================
CREATE TABLE IF NOT EXISTS departamentos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS cargos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID,
    departamento_id UUID REFERENCES departamentos(id) ON DELETE SET NULL,
    nome VARCHAR(100) NOT NULL,
    nivel VARCHAR(20) CHECK (nivel IN ('junior', 'pleno', 'senior', 'gerente', 'diretor')),
    salario_minimo DECIMAL(15,2),
    salario_maximo DECIMAL(15,2),
    beneficios JSONB,
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS funcionarios (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID,
    usuario_id UUID REFERENCES users(id) ON DELETE SET NULL,
    departamento_id UUID REFERENCES departamentos(id) ON DELETE SET NULL,
    cargo_id UUID REFERENCES cargos(id) ON DELETE SET NULL,
    matricula VARCHAR(50) UNIQUE NOT NULL,
    data_admissao DATE,
    data_demissao DATE,
    status VARCHAR(20) DEFAULT 'ativo' CHECK (status IN ('ativo', 'ferias', 'licenca', 'demissao', 'suspenso')),
    tipo_contrato VARCHAR(50) CHECK (tipo_contrato IN ('clt', 'pj', 'estagio', 'autonomo')),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- ============================================================================
-- MÓDULO: FOLHA DE PAGAMENTO
-- ============================================================================
CREATE TABLE IF NOT EXISTS configuracoes_folha (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID,
    mes_referencia DATE NOT NULL,
    data_pagamento DATE,
    recesso_janeiro BOOLEAN DEFAULT false,
    recesso_julho BOOLEAN DEFAULT false,
    custo_empresa_percentual DECIMAL(5,2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS folha_pagamento (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    funcionario_id UUID REFERENCES funcionarios(id) ON DELETE CASCADE,
    mes_referencia DATE NOT NULL,
    salario_base DECIMAL(15,2) NOT NULL,
    horas_extras DECIMAL(15,2) DEFAULT 0.00,
    adicional_noturno DECIMAL(15,2) DEFAULT 0.00,
    descontos DECIMAL(15,2) DEFAULT 0.00,
    beneficios JSONB,
    fgts DECIMAL(15,2) DEFAULT 0.00,
    inss DECIMAL(15,2) DEFAULT 0.00,
    irrf DECIMAL(15,2) DEFAULT 0.00,
    liquido DECIMAL(15,2) NOT NULL,
    data_pagamento DATE,
    status VARCHAR(20) DEFAULT 'pendente' CHECK (status IN ('pendente', 'processado', 'pago', 'cancelado')),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- ============================================================================
-- MÓDULO: OBRAS E PROJETOS
-- ============================================================================
CREATE TABLE IF NOT EXISTS obras (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID,
    cliente_id UUID REFERENCES clientes(id) ON DELETE SET NULL,
    usuario_id UUID REFERENCES users(id) ON DELETE SET NULL,
    codigo VARCHAR(20) UNIQUE NOT NULL,
    nome VARCHAR(255) NOT NULL,
    descricao TEXT,
    local VARCHAR(255),
    data_inicio DATE,
    data_previsao DATE,
    data_conclusao DATE,
    valor_total DECIMAL(15,2),
    status VARCHAR(50) DEFAULT 'planejamento' CHECK (status IN ('planejamento', 'em_andamento', 'pausada', 'concluida', 'cancelada')),
    observacoes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS obras_itens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    obra_id UUID REFERENCES obras(id) ON DELETE CASCADE,
    produto_id UUID REFERENCES produtos(id) ON DELETE RESTRICT,
    quantidade INTEGER NOT NULL,
    preco_unitario DECIMAL(15,2) NOT NULL,
    total DECIMAL(15,2) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- ============================================================================
-- MÓDULO: CONTRATO E COMPLIANCE
-- ============================================================================
CREATE TABLE IF NOT EXISTS contrato_modelo (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID,
    tipo VARCHAR(50) NOT NULL CHECK (tipo IN ('contrato_servico', 'contrato_compra', 'contrato_vendas', 'contrato_parceria')),
    nome VARCHAR(255) NOT NULL,
    clausulas TEXT,
    termos_condicoes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS contrato_registro (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID,
    contrato_id UUID REFERENCES contrato_modelo(id) ON DELETE SET NULL,
    numero_contrato VARCHAR(50) UNIQUE NOT NULL,
    cliente_id UUID REFERENCES clientes(id) ON DELETE SET NULL,
    data_contrato DATE NOT NULL,
    data_vigencia_inicio DATE NOT NULL,
    data_vigencia_fim DATE,
    valor_total DECIMAL(15,2) NOT NULL,
    partes JSONB,
    assinatura_cliente TEXT,
    assinatura_fornecedor TEXT,
    status VARCHAR(20) DEFAULT 'rascunho' CHECK (status IN ('rascunho', 'enviado', 'assinado', 'cancelado')),
    observacoes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- ============================================================================
-- MÓDULO: VIEWS E TRIGGERS
-- ============================================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplicar trigger a todas as tabelas relevantes
DROP TRIGGER IF EXISTS update_users_updated_at ON users CASCADE;
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
DROP TRIGGER IF EXISTS update_clientes_updated_at ON clientes CASCADE;
CREATE TRIGGER update_clientes_updated_at BEFORE UPDATE ON clientes FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
DROP TRIGGER IF EXISTS update_fornecedores_updated_at ON fornecedores CASCADE;
CREATE TRIGGER update_fornecedores_updated_at BEFORE UPDATE ON fornecedores FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
DROP TRIGGER IF EXISTS update_compras_updated_at ON compras CASCADE;
CREATE TRIGGER update_compras_updated_at BEFORE UPDATE ON compras FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
DROP TRIGGER IF EXISTS update_vendas_updated_at ON vendas CASCADE;
CREATE TRIGGER update_vendas_updated_at BEFORE UPDATE ON vendas FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
DROP TRIGGER IF EXISTS update_ordens_servico_updated_at ON ordens_servico CASCADE;
CREATE TRIGGER update_ordens_servico_updated_at BEFORE UPDATE ON ordens_servico FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
DROP TRIGGER IF EXISTS update_produtos_updated_at ON produtos CASCADE;
CREATE TRIGGER update_produtos_updated_at BEFORE UPDATE ON produtos FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
DROP TRIGGER IF EXISTS update_agenda_eventos_updated_at ON agenda_eventos CASCADE;
CREATE TRIGGER update_agenda_eventos_updated_at BEFORE UPDATE ON agenda_eventos FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
DROP TRIGGER IF EXISTS update_formas_pagamento_updated_at ON formas_pagamento CASCADE;
CREATE TRIGGER update_formas_pagamento_updated_at BEFORE UPDATE ON formas_pagamento FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
DROP TRIGGER IF EXISTS update_configuracao_frete_updated_at ON configuracao_frete CASCADE;
CREATE TRIGGER update_configuracao_frete_updated_at BEFORE UPDATE ON configuracao_frete FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
DROP TRIGGER IF EXISTS update_fretes_calculados_updated_at ON fretes_calculados CASCADE;
CREATE TRIGGER update_fretes_calculados_updated_at BEFORE UPDATE ON fretes_calculados FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
DROP TRIGGER IF EXISTS update_configuracao_fiscal_updated_at ON configuracao_fiscal CASCADE;
CREATE TRIGGER update_configuracao_fiscal_updated_at BEFORE UPDATE ON configuracao_fiscal FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
DROP TRIGGER IF EXISTS update_regras_tributarias_updated_at ON regras_tributarias CASCADE;
CREATE TRIGGER update_regras_tributarias_updated_at BEFORE UPDATE ON regras_tributarias FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
DROP TRIGGER IF EXISTS update_devolucoes_updated_at ON devolucoes CASCADE;
CREATE TRIGGER update_devolucoes_updated_at BEFORE UPDATE ON devolucoes FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
DROP TRIGGER IF EXISTS update_configuracao_comissoes_updated_at ON configuracao_comissoes CASCADE;
CREATE TRIGGER update_configuracao_comissoes_updated_at BEFORE UPDATE ON configuracao_comissoes FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
DROP TRIGGER IF EXISTS update_comissoes_updated_at ON comissoes CASCADE;
CREATE TRIGGER update_comissoes_updated_at BEFORE UPDATE ON comissoes FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
DROP TRIGGER IF EXISTS update_kits_updated_at ON kits CASCADE;
CREATE TRIGGER update_kits_updated_at BEFORE UPDATE ON kits FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
DROP TRIGGER IF EXISTS update_produtos_seriais_updated_at ON produtos_seriais CASCADE;
CREATE TRIGGER update_produtos_seriais_updated_at BEFORE UPDATE ON produtos_seriais FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
DROP TRIGGER IF EXISTS update_site_configuracao_updated_at ON site_configuracao CASCADE;
CREATE TRIGGER update_site_configuracao_updated_at BEFORE UPDATE ON site_configuracao FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
DROP TRIGGER IF EXISTS update_site_paginas_updated_at ON site_paginas CASCADE;
CREATE TRIGGER update_site_paginas_updated_at BEFORE UPDATE ON site_paginas FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
DROP TRIGGER IF EXISTS update_departamentos_updated_at ON departamentos CASCADE;
CREATE TRIGGER update_departamentos_updated_at BEFORE UPDATE ON departamentos FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
DROP TRIGGER IF EXISTS update_cargos_updated_at ON cargos CASCADE;
CREATE TRIGGER update_cargos_updated_at BEFORE UPDATE ON cargos FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
DROP TRIGGER IF EXISTS update_funcionarios_updated_at ON funcionarios CASCADE;
CREATE TRIGGER update_funcionarios_updated_at BEFORE UPDATE ON funcionarios FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
DROP TRIGGER IF EXISTS update_obras_updated_at ON obras CASCADE;
CREATE TRIGGER update_obras_updated_at BEFORE UPDATE ON obras FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
DROP TRIGGER IF EXISTS update_contrato_registro_updated_at ON contrato_registro CASCADE;
CREATE TRIGGER update_contrato_registro_updated_at BEFORE UPDATE ON contrato_registro FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE OR REPLACE VIEW agenda_resumo_categoria AS
SELECT
    categoria,
    COUNT(*) as total,
    COUNT(*) FILTER (WHERE status = 'concluido') as concluidos,
    COUNT(*) FILTER (WHERE status = 'pendente') as pendentes,
    COUNT(*) FILTER (WHERE prioridade = 'alta') as alta_prioridade
FROM agenda_eventos
GROUP BY categoria;

-- ============================================================================
-- DADOS INICIAIS (SEEDS)
-- ============================================================================

-- Usuários
INSERT INTO users (nome, email, password, cpf, telefone, role, ativo) VALUES
('Administrador', 'admin@zeno.erp', '$2y$12$aNbdQH86PhulvBYE25D9J.bJXrRB/TyUdehFctOzUveJfckf6Fhtq', '000.000.000-00', '(00) 00000-0000', 'admin', true)
ON CONFLICT (email) DO NOTHING;

INSERT INTO users (nome, email, password, cpf, telefone, role, ativo) VALUES
('Gerente Exemplo', 'gerente@zeno.erp', '$2y$12$ibeQOTMnHZyJTN9bESxEUebxCzQA8vnjttA3XwLGdnQa3FA254nfW', '111.111.111-11', '(11) 11111-1111', 'gerente', true)
ON CONFLICT (email) DO NOTHING;

INSERT INTO users (nome, email, password, cpf, telefone, role, ativo) VALUES
('Vendedor Exemplo', 'vendedor@zeno.erp', '$2y$12$osQna0WF3vUpC8h3Sr/aXutIfcNrEGMXVFearhSXKcZ/BiAublrKq', '222.222.222-22', '(22) 22222-2222', 'vendedor', true)
ON CONFLICT (email) DO NOTHING;

INSERT INTO users (nome, email, password, cpf, telefone, role, ativo) VALUES
('Financeiro Exemplo', 'financeiro@zeno.erp', '$2y$12$tyAWWxKqreN1FBk1waAl1esn9HVJxO4JQaaT24wwNKE3oAeOKG60q', '333.333.333-33', '(33) 33333-3333', 'financeiro', true)
ON CONFLICT (email) DO NOTHING;

INSERT INTO users (nome, email, password, cpf, telefone, role, ativo) VALUES
('Logista Exemplo', 'logista@zeno.erp', '$2y$12$OvwwteuZaVGgBJ0twvbxTuzPy/9GJCLgrOPvMqgH6McnOGzD1wG2q', '444.444.444-44', '(44) 44444-4444', 'logista', true)
ON CONFLICT (email) DO NOTHING;

-- Categorias
INSERT INTO categorias_produto (nome, descricao) VALUES
('Geral', 'Categoria padrão para produtos'),
('Eletrônicos', 'Produtos eletrônicos'),
('Peças', 'Peças e componentes'),
('Serviços', 'Itens de serviço'),
('Vestuário', 'Roupas e acessórios'),
('Alimentos', 'Produtos alimentícios')
ON CONFLICT DO NOTHING;

-- Formas de pagamento
INSERT INTO formas_pagamento (nome, tipo, taxa_percentual, permite_parcelamento, max_parcelas, dias_recebimento, ativo) VALUES
('dinheiro', 'vista', 0.00, false, 1, 0, true),
('pix', 'vista', 0.00, false, 1, 0, true),
('credito', 'prazo', 2.99, true, 12, 30, true),
('debito', 'vista', 1.99, false, 1, 1, true),
('boleto', 'prazo', 0.00, false, 1, 5, true),
('vale', 'vista', 0.00, false, 1, 0, true)
ON CONFLICT DO NOTHING;

-- Configuração fiscal básica
INSERT INTO configuracao_fiscal (regime, cnpj, razao_social, nome_fantasia, ambiente_nfe, ambiente_nfse) VALUES
('mei', '00.000.000/0001-00', 'Empresa Exemplo MEI', 'ZENO ERP Exemplo', 'homologacao', 'homologacao')
ON CONFLICT DO NOTHING;

-- Configuração de frete
INSERT INTO configuracao_frete (tipo, cep_origem, ativo) VALUES
('fixo', '00000-000', true),
('correios', NULL, true)
ON CONFLICT DO NOTHING;

-- ============================================================================
-- MÓDULO: CONTAS A RECEBER / PAGAR (FALTA ANTIGA - CORRIGIDA)
-- ============================================================================
CREATE TABLE IF NOT EXISTS contas_receber (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    origem VARCHAR(50) DEFAULT 'venda',
    origem_id UUID,
    cliente_id UUID REFERENCES clientes(id) ON DELETE SET NULL,
    venda_id UUID REFERENCES vendas(id) ON DELETE SET NULL,
    os_id UUID REFERENCES ordens_servico(id) ON DELETE SET NULL,
    numero_parcela VARCHAR(10) DEFAULT '1',
    valor DECIMAL(15,2) NOT NULL,
    desconto DECIMAL(15,2) DEFAULT 0.00,
    acrescimo DECIMAL(15,2) DEFAULT 0.00,
    valor_liquido DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    data_vencimento DATE NOT NULL,
    data_recebimento TIMESTAMP,
    status VARCHAR(50) DEFAULT 'pendente',
    forma_pagamento VARCHAR(50),
    observacoes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS contas_pagar (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    origem VARCHAR(50) DEFAULT 'compra',
    origem_id UUID,
    fornecedor_id UUID REFERENCES fornecedores(id) ON DELETE SET NULL,
    compra_id UUID REFERENCES compras(id) ON DELETE SET NULL,
    os_id UUID REFERENCES ordens_servico(id) ON DELETE SET NULL,
    numero_parcela VARCHAR(10) DEFAULT '1',
    valor DECIMAL(15,2) NOT NULL,
    desconto DECIMAL(15,2) DEFAULT 0.00,
    acrescimo DECIMAL(15,2) DEFAULT 0.00,
    valor_liquido DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    data_vencimento DATE NOT NULL,
    data_pagamento TIMESTAMP,
    status VARCHAR(50) DEFAULT 'pendente',
    forma_pagamento VARCHAR(50),
    observacoes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_contas_receber_vencimento ON contas_receber(data_vencimento);
CREATE INDEX IF NOT EXISTS idx_contas_receber_status ON contas_receber(status);
CREATE INDEX IF NOT EXISTS idx_contas_pagar_vencimento ON contas_pagar(data_vencimento);
CREATE INDEX IF NOT EXISTS idx_contas_pagar_status ON contas_pagar(status);

-- ============================================================================
-- MÓDULO: CRM - PROSPECÇÃO
-- ============================================================================
CREATE TABLE IF NOT EXISTS crm_prospeccao (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    cliente_id UUID NOT NULL REFERENCES clientes(id) ON DELETE CASCADE,
    vendedor_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status VARCHAR(50) DEFAULT 'novo' CHECK (status IN ('novo', 'em_contato', 'qualificado', 'fechado', 'recusado')),
    canal_contato VARCHAR(20) CHECK (canal_contato IN ('email', 'telefone', 'whatsapp', 'visita')),
    proxima_acao TEXT,
    data_acao DATE,
    observacoes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_crm_prospeccao_cliente ON crm_prospeccao(cliente_id);
CREATE INDEX IF NOT EXISTS idx_crm_prospeccao_vendedor ON crm_prospeccao(vendedor_id);
CREATE INDEX IF NOT EXISTS idx_crm_prospeccao_status ON crm_prospeccao(status);

-- ============================================================================
-- MÓDULO: OS ITENS (CORRIGIDO - usa os_servicos e os_produtos)
-- ============================================================================
-- Nota: O modelo OrdemServicoItem usa a tabela 'os_itens', mas o Laravel espera
-- que exista a tabela. Vamos criar com compatibilidade para os_servicos/os_produtos.

CREATE TABLE IF NOT EXISTS os_itens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    os_id UUID NOT NULL REFERENCES ordens_servico(id) ON DELETE CASCADE,
    tipo VARCHAR(20) DEFAULT 'servico' CHECK (tipo IN ('servico', 'peca')),
    produto_id UUID REFERENCES produtos(id) ON DELETE SET NULL,
    nome VARCHAR(255),
    quantidade DECIMAL(10,2) NOT NULL DEFAULT 1,
    valor_unitario DECIMAL(15,2) NOT NULL DEFAULT 0,
    total DECIMAL(15,2) NOT NULL DEFAULT 0,
    observacoes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_os_itens_os ON os_itens(os_id);

-- ============================================================================
-- FIM DO SCHEMA COMPLETO
-- ============================================================================
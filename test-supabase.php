<?php
require 'vendor/autoload.php';
$app = require_once 'bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "=== TESTANDO SUPABASE PARA VENDAS/PDV ===\n\n";

try {
    // Testar modelo Produto
    $produtos = \App\Models\Produto::all();
    echo "📦 PRODUTOS: " . count($produtos) . "\n";
    foreach ($produtos as $p) {
        echo "  - {$p->nome} | R$ {$p->preco_venda} | Estoque: {$p->estoque_atual}\n";
    }
    
    // Testar modelo Cliente
    $clientes = \App\Models\Cliente::all();
    echo "👥 CLIENTES: " . count($clientes) . "\n";
    foreach ($clientes as $c) {
        echo "  - {$c->nome}\n";
    }
    
    // Testar modelo Fornecedor
    $fornecedores = \App\Models\Fornecedor::all();
    echo "🚚 FORNECEDORES: " . count($fornecedores) . "\n";
    foreach ($fornecedores as $f) {
        echo "  - {$f->nome}\n";
    }
    
    // Testar migrações para vendas
    echo "\n=== ROTAS DE VENDAS ===\n";
    $routes = \Illuminate\Support\Facades\Artisan::call('route:list');
    
    // Verificar rotas Vendas
    $router = \Illuminate\Support\Facades\Route::getRoutes();
    foreach ($router as $route) {
        if (strpos($route->getName(), 'vendas') !== false || strpos($route->uri(), '/vendas') !== false) {
            echo "✅ Rota: {$route->uri()} - {$route->getName()}\n";
        }
    }
    
    echo "\n✅ Tudo OK! Supabase está funcional para o projeto Zeno!\n";
    
} catch (\Exception $e) {
    echo "❌ ERRO: " . $e->getMessage() . "\n\n";
    echo "Possíveis causas:\n";
    echo "1. Senha incorreta\n";
    echo "2. Tabelas não existem\n";
    echo "3. Banco de dados não existe\n";
}

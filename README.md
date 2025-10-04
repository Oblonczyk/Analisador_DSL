## Como Executar o Programa

Para validar os scripts de teste, o analisador deve ser executado através da linha de comando, utilizando o motor Godot em modo *headless* (sem interface gráfica).

### Pré-requisitos

* **Godot Engine (versão 4.x ou superior)** baixado no computador.

### Passo 1: Localizar o Executável do Godot

Antes de executar os comandos, você precisa saber onde o executável do Godot está localizado no seu computador.

1.  Navegue até a pasta onde você extraiu os arquivos do Godot.
2.  Encontre o arquivo executável. O nome será algo como `Godot_v4.2.2-stable_win64.exe`.
3.  Mantenha esta pasta aberta, pois você precisará do caminho para este arquivo.

### Passo 2: Executar os Testes via Linha de Comando

1.  Abra um terminal (PowerShell, CMD, etc.) na pasta raiz deste projeto (onde o arquivo `analisador.gd` está localizado).
2.  Você irá montar o comando usando o caminho completo para o executável que você localizou no Passo 1.

    **Dica:** A maneira mais fácil de fazer isso é **arrastar o arquivo `.exe` do Godot e soltá-lo** diretamente na janela do terminal. Isso colará o caminho completo e correto automaticamente.

3.  Depois de colar o caminho, digite o resto do comando. A estrutura será:

    `"<Caminho_Completo_Para_o_Godot.exe>" --headless --script analisador.gd <nome_do_arquivo>`

#### Exemplo para Teste de Sucesso

Execute o comando abaixo para analisar o arquivo `teste_sucesso.txt`. Lembre-se de substituir o caminho de exemplo pelo caminho real do seu executável.

```sh
# Exemplo de comando:
& "C:\Users\SeuUsuario\Downloads\Godot_v4.2.2-stable_win64.exe" --headless --script analisador.gd teste_sucesso.txt
```

**Saída Esperada:**
```
--- File analisys initializing: teste_sucesso.txt ---
SUCESS: The script sintax is valid!
```

#### Exemplo para Teste de Falha

Execute o comando abaixo para analisar o arquivo `teste_falha.txt`.

```sh
# Exemplo de comando:
& "C:\Users\SeuUsuario\Downloads\Godot_v4.2.2-stable_win64.exe" --headless --script analisador.gd teste_falha.txt
```

**Saída Esperada:**
```
--- File analisys initializing: teste_falha.txt ---
ERROR: Erro Sintático: Expected ']' to finish the button list.
   at: push_error (core/variant/variant_utility.cpp:1098)
ERROR: Sintatical Error: Expected a parameter after comma
   at: push_error (core/variant/variant_utility.cpp:1098)
ERROR: The script has sintax erros.
```
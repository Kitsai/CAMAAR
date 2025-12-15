# Detalhes do sistema

Este sistema utiliza ruby on rails na versão 3.4.7  do ruby.

É recomendado que se utilize o rbenv para gerenciar as versões do ruby no linux

O sistema de banco de dados utilizado é um sqlite para inicializá-lo
deve-se rodar as migrations.

```bash
# Entre no diretório do projeto rails
cd CAMAAR/CAMAAR

# Aplique as migracoes
rails db:migrate

# Crie o usuário padrão de admin
rails db:seed

# Rode o sistema
rails server
```

O seed irá criar um usuário admin padrão.
Suas credenciais são:

email: <admin@camaar.com>
senha: admin123

## Cadastrando senha de usuário

Como um admin você consegue importar dados do sigaa que automaticamente cadastra usuarios no sistema. Porém é necessario configurar a senha desses usuários.

Após importado os dados acesse a rota:

> /set_password?email=<email para cadastrar senha>

# Instalação

## Ambiente Ruby

Em vez de usar o Ruby da distribuição é recomendado instalar o próprio ambiente Ruby. O primeiro passo é instalar o `rbenv`.

```sh
sudo git clone https://github.com/rbenv/rbenv.git /opt/rbenv
```

Crie um shell script de perfil para adicionar a configuração de variáveis de ambiente e inicialização do `rbenv`. O arquivo pode ter qualquer nome, mas deve estar contido em `/etc/profile.d`.

Cole o seguinte conteúdo no arquivo:

```sh
#!/bin/sh
export RBENV_ROOT="/opt/rbenv"
eval "$(/opt/rbenv/bin/rbenv init - --no-rehash bash)"
```

Certifique-se de que o arquivo tem permissão de execução, saia e faça login no shell novamente para continuar.

Para que o `rbenv` consiga compilar o Ruby será preciso instalar o `ruby-build`:

```sh
sudo git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build
```

Instale também o pacote essencial de ferramentas e bibliotecas de compilação do Linux:

```sh
sudo apt install build-essential
```

Pronto! Agora já é possível instalar o Ruby. Instale via `rbenv` especificando a versão. Certifique-se de estar usando a versão correspondente à do arquivo `.ruby-version` deste projeto.

```sh
rbenv install 3.1.2
```

## Deploy da aplicação

Gere uma chave SSH pública no host e adicione no GitHub para poder acessar o repositório.

```sh
ssh-keygen
cat ~/.ssh/id_rsa.pub
```

Clone o repositório no diretório raíz do domínio do site.

```sh
git clone git@github.com:jpjust/papacapim.git caminho_do_diretório
```

Faça uma cópia do `.env.example` para `.env` e preencha com os dados do banco de dados.

```sh
cp .env.example .env
nano .env
```

Instale as dependências do projeto.

```sh
bundle install
```

Gere uma chave secreta da aplicação e adicione no `.env`.

```sh
echo SECRET_KEY_BASE=`bundle exec rake secret` >> .env
```

Proteja alguns diretórios contra acesso indevido de outros usuários (caso esteja usando uma hospedagem compartilhada).

```sh
chmod 700 config db .env
chmod 600 config/database.yml config/secrets.yml
```

Faça a migração inicial do banco de dados.

```sh
bundle exec rake db:migrate RAILS_ENV=production
```

## Deploy com Passenger

Caso esteja em uma hospedagem compartilhada e queira usar o Passenger, verifique o arquivo `.htaccess`. É preciso indicar o caminho do wrapper do Ruby. O caminho do wrapper pode ser encontrado da seguinte forma:

```sh
passenger-config about ruby-command
```

O arquivo deve parecer como este (a segunda linha habilita mensagens amigáveis na tela de erro):

```sh
PassengerRuby /opt/rbenv/versions/3.1.2/bin/ruby
# PassengerFriendlyErrorPages on
```

Caso esteja rodando Apache 2 em uma VM, instale o pacote `libapache2-mod-passenger` e crie a seguinte configuração para a aplicação:

```
<VirtualHost *:80>
    ServerName api.papacapim.just.pro.br
    ServerAdmin app@just.pro.br
    DocumentRoot /var/www/papacapim/public

    # Certifique-se de apontar para o caminho da versão correta do Ruby
    PassengerRuby /opt/rbenv/versions/3.1.2/bin/ruby

    # APENAS PARA USO EM AMBIENTE DE TESTE: habilita mensagens amigáveis na tela de erro
    # PassengerFriendlyErrorPages on

    # Opcional: caminhos personalizados para os logs do Apache
    ErrorLog /var/log/apache2/api.papacapim.just.pro.br/error.log
    CustomLog /var/log/apache2/api.papacapim.just.pro.br/access.log combined
</VirtualHost>
```

Para ativar a configuração, execute:

```sh
a2ensite
```

## Deploy com Puma

No caso de usar o Puma, copie o arquivo `puma-papacapim.service` para `/etc/systemd/system` e ative o serviço:

```sh
cp puma-papacapim.service /etc/systemd/system
systemctl daemon-reload
systemctl enable puma-papacapim
systemctl start puma-papacapim
```

No arquivo de configuração do Virtual Host no Apache será preciso fazer um proxy reverso para o processo do Puma:

```
<VirtualHost *:80>
    ServerName api.papacapim.just.pro.br
    ServerAdmin app@just.pro.br
    DocumentRoot /var/www/papacapim/public

    # Proxy reverso para o Puma
    ProxyPreserveHost On
    ProxyPass / http://127.0.0.1:3002/
    ProxyPassReverse / http://127.0.0.1:3002/

    # Opcional: caminhos personalizados para os logs do Apache
    ErrorLog /var/log/apache2/api.papacapim.just.pro.br/error.log
    CustomLog /var/log/apache2/api.papacapim.just.pro.br/access.log combined
</VirtualHost>
```

Para ativar a configuração, execute:

```sh
a2ensite
```

## Configuração HTTPS

Para ativar a camada TLS iremos usar o Certbot. Comece instalando os pacotes:

```sh
sudo apt install certbot python3-certbot-apache
```

Após instalar os pacotes, execute o Certbot:

```sh
certbot
```

O Certbot irá solicitar alguns dados. Ao final, basta escolher o domínio correspondente à sua aplicação e ELE fará a configuração automática no arquivo de configuração correspondente no Apache. Finalmente, recarregue o Apache:

```sh
systemctl reload apache2.service
```

## HTTP 2

É recomendado usar HTTP 2 ativando o módulo correspondente no Apache:

```sh
a2enmod http2
```

# Imagem base
FROM ubuntu:latest

# Atualizar pacotes do sistema
RUN apt-get update
RUN apt-get upgrade -y

# Instalando dependencias
RUN apt-get install -y curl
RUN apt-get install -y unzip
RUN apt-get install -y alien

# Instalação Python e gerenciador pip
RUN apt-get install -y libssl-dev libffi-dev python3-dev
RUN apt-get install -y python3 python3-pip

# Definindo o Python padrão como python3
RUN ln -s /usr/bin/python3 /usr/bin/python

# Instalando a lib delta-sharing (Python)
RUN pip install delta-sharing

# Jogando o arquivo de configuração do snowsql para a pasta raiz de instalação
WORKDIR /root/.snowsql
COPY config /root/.snowsql

# Definindo o diretório de trabalho e copiando os arquivos .py e arquivo de acesso ao delta share
WORKDIR /data
COPY delta.py /data
COPY config.share /data

# Fazendo o download do arquivo de instalação do snowsql e transformando ele em arquivo .deb para fazer a instalação
RUN curl -O https://sfc-repo.snowflakecomputing.com/snowsql/bootstrap/1.2/linux_x86_64/snowflake-snowsql-1.2.26-1.x86_64.rpm
RUN alien snowflake-snowsql-1.2.26-1.x86_64.rpm
RUN dpkg -i snowflake-snowsql_1.2.26-2_amd64.deb

# Rodando o script para consumir os dados de delta share
RUN python delta.py

# Executando comando para copiar os dados para uma internal stage
ENTRYPOINT [ "snowsql" ]
CMD [ "-q put file:///data/taxi.parquet @SNOWSQL_STAGE;" ]
# 1. Uma máquina com Python (versão fixada, nada de "latest")
FROM python:3.12-slim

# 2. Entrar na pasta de trabalho dentro do container
WORKDIR /app

# 3. Instalar as dependências
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 4. Colocar o código no lugar
COPY app/ ./app/

# Não rodar como root (mínimo privilégio)
RUN useradd --create-home appuser
USER appuser

# 5. Documentar a porta e definir o comando de inicialização
EXPOSE 8080
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8080"]
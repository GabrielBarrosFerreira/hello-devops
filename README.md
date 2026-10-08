# hello-devops

Exercício prático de DevOps na Prática (UFLA, 2026/2): Docker, GitHub Actions e Container Registry.

Aplicação Python/FastAPI com o endpoint `GET /hello`.

## Executar localmente

    docker build -t minha-aplicacao:1.0 .
    docker run --rm -p 8080:8080 minha-aplicacao:1.0
    curl http://localhost:8080/hello
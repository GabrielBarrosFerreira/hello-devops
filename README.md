# hello-devops

![Docker - build e push](https://github.com/GabrielBarrosFerreira/hello-devops/actions/workflows/docker.yml/badge.svg)

Exercício prático da disciplina **DevOps na Prática** (UFLA, 2026/2): Docker, GitHub Actions e Container Registry.

Aplicação **Python / FastAPI** com um endpoint HTTP, empacotada em uma imagem Docker que é construída, testada e publicada automaticamente no **GitHub Container Registry (GHCR)** a cada push na branch `main`.

```
Desenvolvedor -> git push -> GitHub -> GitHub Actions -> build e teste da imagem
              -> push para o GHCR -> docker pull -> execução local -> teste do endpoint
```

## Links

| Item | Link |
|---|---|
| Repositório | https://github.com/GabrielBarrosFerreira/hello-devops |
| Execuções da pipeline | https://github.com/GabrielBarrosFerreira/hello-devops/actions |
| Imagem no registry | https://github.com/users/GabrielBarrosFerreira/packages/container/package/hello-devops |

## Estrutura

```
.github/workflows/docker.yml   # pipeline de build, teste e publicação
app/__init__.py                # marca a pasta app como pacote Python
app/main.py                    # aplicação (endpoint GET /hello)
Dockerfile                     # receita da imagem
.dockerignore                  # o que não vai para o build
.gitignore                     # o que não vai para o Git
requirements.txt               # dependências com versões fixadas
```

## Aplicação

| Versão | `GET /hello` responde |
|---|---|
| 1.0 | `Hello World` |
| 2.0 | `Hello World 2` |

A resposta é texto puro (`text/plain`), não JSON.

## Executar localmente

```bash
docker build -t minha-aplicacao:1.0 .
docker run --rm -p 8080:8080 minha-aplicacao:1.0
curl http://localhost:8080/hello
```

O Dockerfile usa a imagem base `python:3.12-slim` (versão fixada), instala as dependências antes de copiar o código (para aproveitar o cache de camadas) e roda a aplicação com um usuário sem privilégios (`appuser`).

## Pipeline (GitHub Actions)

Arquivo: [`.github/workflows/docker.yml`](.github/workflows/docker.yml). Disparada automaticamente em todo `push` na `main`.

| Step | O que faz |
|---|---|
| Baixar o código | `actions/checkout` clona o repositório na máquina virtual |
| Build da imagem | `docker build` com o nome `ghcr.io/gabrielbarrosferreira/hello-devops:<TAG>` |
| Verificar a imagem | confirma que a imagem existe, sobe o container e testa o `/hello` com `curl -f`; se não responder, a pipeline falha e nada é publicado |
| Login no GHCR | `docker login` usando os Secrets `REGISTRY_USERNAME` e `REGISTRY_TOKEN` via `--password-stdin` |
| Publicar a imagem | `docker push` da tag definida na variável `TAG` |

**Credenciais:** nenhuma credencial aparece no arquivo da pipeline. Elas ficam em *Settings → Secrets and variables → Actions* e aparecem mascaradas (`***`) nos logs.

### Histórico de execuções

| # | Commit | Resultado |
|---|---|---|
| 1 | `ci: pipeline de build e publicacao da imagem no GHCR` | ❌ o teste do endpoint rodou antes de o container ficar pronto (`curl` exit 56). O gate funcionou: **nenhuma imagem foi publicada** |
| 2 | `fix(ci): repete o teste do endpoint ate o container ficar pronto` | ✅ publicou a tag `1.0` |
| 3 | `feat(api): altera resposta do /hello para Hello World 2` | ✅ publicou a tag `2.0` |

## Imagens publicadas

| Tag | Digest |
|---|---|
| `1.0` | `sha256:57ba06db22e8d688efc7d105ff225265595a802be05d0f1f14fa3efb39bd74dc` |
| `2.0` | `sha256:6605ff5d85cd1281ec54a5753f2aa024932b5a3ac22a8ac5531da25c754b28cf` |

O digest exibido no `docker pull` é idêntico ao registrado no log da pipeline, o que comprova que a imagem executada localmente é exatamente a que foi construída e testada no GitHub Actions.

### Validar a partir do registry

```bash
# versão 1.0
docker pull ghcr.io/gabrielbarrosferreira/hello-devops:1.0
docker run --rm -p 8080:8080 ghcr.io/gabrielbarrosferreira/hello-devops:1.0
curl http://localhost:8080/hello      # -> Hello World

# versão 2.0
docker pull ghcr.io/gabrielbarrosferreira/hello-devops:2.0
docker run --rm -p 8080:8080 ghcr.io/gabrielbarrosferreira/hello-devops:2.0
curl http://localhost:8080/hello      # -> Hello World 2
```

As duas tags convivem no registry: publicar a `2.0` não alterou a `1.0`, o que permite voltar à versão anterior (rollback) a qualquer momento.
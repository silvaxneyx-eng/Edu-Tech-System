# MS Office setup — Instalação para técnico

Instalação oficial do **Office LTSC Professional Plus 2024** **sem ativação**.
O cliente compra a chave depois e ativa quando quiser.

## Fluxo resumido

```
Instalar (sem chave) → Cliente usa limitado → Cliente compra key → Ativar
```

---

## 1. Preparar a pasta

```powershell
# PowerShell como Administrador
.\scripts\01-Criar-Pasta.ps1
```

Cria: `C:\MS Office setup\`

---

## 2. Office Customization Tool (OCT)

**Link:** https://config.office.com/deploymentsettings

| Opção | Valor |
|-------|--------|
| Architecture | 64-bit (ou 32-bit conforme o PC) |
| Product | Office LTSC Professional Plus 2024 |
| License | **Retail** se o cliente vai comprar key retail; **Volume** se for MAK/KMS |
| Language | Match operating system |
| Product key | **Deixe em branco** (não informe chave) |

Exporte → **Office Open XML** → salve como `configuração.xml` → mova para `C:\MS Office setup\`

> **Importante:** o tipo de licença no OCT deve combinar com a chave que o cliente vai comprar (retail ≠ volume).

---

## 3. Office Deployment Tool (ODT)

**Download:** https://www.microsoft.com/en-us/download/details.aspx?id=49117

Mova o `.exe` para `C:\MS Office setup\` e extraia:

```powershell
.\scripts\02-Extrair-ODT.ps1 -OdtExe "C:\MS Office setup\officedeploymenttool_*.exe"
```

---

## 4. Download offline (recomendado para ISO/pendrive)

```powershell
.\scripts\03-Baixar-Office.ps1
```

---

## 5. Instalar (sem ativação)

**CMD como Administrador** (igual ao tutorial):

```cmd
cd /d "C:\MS Office setup"
setup.exe /configure configuração.xml
```

Ou:

```powershell
.\scripts\04-Instalar-Office.ps1
```

O Office instala e fica **não licenciado** até o cliente ativar.

---

## 6. Quando o cliente comprar a chave

```powershell
.\scripts\05-Ativar-Com-Chave.ps1 -Chave "XXXXX-XXXXX-XXXXX-XXXXX-XXXXX"
```

Verificar status:

```powershell
.\scripts\06-Ver-Status.ps1
```

Entregue também o arquivo `LEIA-ME-CLIENTE.txt` para o cliente.

---

## O que o cliente vê sem ativação

- Office abre normalmente por um período
- Barra amarela: **“Produto não licenciado”**
- Depois de um tempo, edição/salvamento podem ser limitados
- Ao inserir a chave válida, tudo libera

---

## Scripts disponíveis

| Script | Função |
|--------|--------|
| `01-Criar-Pasta.ps1` | Cria `C:\MS Office setup` |
| `02-Extrair-ODT.ps1` | Extrai o ODT |
| `03-Baixar-Office.ps1` | Download offline |
| `04-Instalar-Office.ps1` | Instala sem chave |
| `05-Ativar-Com-Chave.ps1` | Ativa quando cliente tiver a key |
| `06-Ver-Status.ps1` | Mostra status da licença |

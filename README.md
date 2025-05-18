# RIT DevOps test – Windows VM automaatne juurutamine Nutanix platvormil

Automatiseeritud töövoog Windows virtuaalmasinate (VM) loomiseks, konfigureerimiseks ja seireks Nutanix AHV keskkonnas, kasutades Terraformi, Ansible't ja Zabbixi API-t.

---

## **Nõuded**

### 1. Nutanix keskkond
- **API juurdepääs**:
  - `NUTANIX_USER`: Nutanix kasutajanimi.
  - `NUTANIX_PASSWORD`: Nutanix parool.
  - `nutanix_endpoint`: Nutanix Prism Central IP-aadress.
- **Windows VM template**:
  - WinRM peab olema aktiveeritud (vt [WinRM seadistus](#winrm-seadistus)).
  - Template UUID (`windows_template_id`).

### 2. Active Directory (AD)
- **Domeeni administraatori konto**:
  - Kasutajanimi: `ad_admin` (määratud Ansible playbookis).
  - Parool: `DOMAIN_ADMIN_PASSWORD` (GitHub Secret).

### 3. Zabbix seire
- **Zabbix server**:
  - IP-aadress: `ZABBIX_SERVER_IP` (GitHub Variable).
  - API kasutaja: `ZABBIX_API_USER` (GitHub Secret).
  - API parool: `ZABBIX_API_PASS` (GitHub Secret).

### 4. GitHub Secrets
- Kõik tundlikud andmed hoitakse turvaliselt:
  - `NUTANIX_USER`, `NUTANIX_PASSWORD`
  - `ADMIN_VM_PASSWORD` (VM lokaalne administraatori parool).
  - `DOMAIN_ADMIN_PASSWORD`, `ZABBIX_API_USER`, `ZABBIX_API_PASS`.

---

## **Kasutusjuhend**

### 1. Repositooriumi kloonimine
```bash
git clone https://github.com/sinu-repo.git
cd nutanix-automation
2. GitHub Secretsi seadistamine
Mine Settings → Secrets and variables → Actions.

Lisa järgmised salasõnad:

NUTANIX_USER, NUTANIX_PASSWORD

ADMIN_VM_PASSWORD, DOMAIN_ADMIN_PASSWORD

ZABBIX_SERVER_IP, ZABBIX_API_USER, ZABBIX_API_PASS.

3. Töövoog GitHub Actionsis
Ava Actions → Deploy Infrastructure → Run workflow.

Vali keskkond (prod või test) ja vajuta Run workflow.

4. Kohalik käivitamine (valikuline)
bash
# Terraform
cd terraform
terraform init
terraform apply -var="admin_vm_password=sinu_parool"

# Ansible
cd ../ansible
ansible-playbook playbook.yml -i inventory/hosts --ask-vault-pass
WinRM Seadistus
Enne templati loomist Nutanixis käivita Windows VM-is:

powershell
# Aktiveeri WinRM
Enable-PSRemoting -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 0
Set-NetFirewallRule -Name "WINRM-HTTP-In-TCP" -RemoteAddress Any

# Lõpeta VM ja loo template
sysprep /generalize /shutdown
Turvalisus
Kõik paroolid ja API võtmed hoitakse GitHub Secretsis.

Ansible kasutab krüpteeritud ühendusi WinRM-iga.

Zabbix API päringud on turvatud HTTPS-iga (kohandatav).

Repositooriumi struktuur
.
├── .github/                  # GitHub Actions töövoogud
│   └── workflows/
│       └── deploy.yml
├── terraform/                # Nutanixi VM-de loomine
│   ├── main.tf
│   ├── variables.tf
│   └── variables.auto.tfvars.example
├── ansible/                  # VM konfiguratsioon ja Zabbix integratsioon
│   ├── playbook.yml
│   ├── roles/
│   └── inventory/
└── README.md
Zabbixi integratsiooni detailid
Hostide automaatne registreerimine: Ansible kasutab Zabbixi API-t, et lisada VM-id seiresüsteemi.

Kasutatavad mallid:

Grupi ID: 2 (Zabbixi vaikimisi "Linux servers" – muuda vastavalt vajadusele).

Malli ID: 10104 (Zabbixi "Template OS Windows" – kontrolli Zabbixi versiooni).

Skaleerimine
Muuda VM-de arvu Terraformi failis terraform/main.tf:

hcl
resource "nutanix_virtual_machine" "windows_vm" {
  count = 5  # Muuda 3 → 5
  # ...
}
Käivita uuesti terraform apply.

Tõrkeotsing
Ansible ei ühendu VM-iga:

Kontrolli WinRM seadeid templatis.

Veendu, et admin_vm_password on õige.

Zabbix ei näe hosti:

Kontrolli Zabbixi API kasutaja õigusi.

Vaata Ansible'i logi (-vvv täpsemaks veateateks).

Litsents ja kontakt
Autor: Pavel Savkin
E-post: pavel.savkin@gmail.com
Litsents: MIT


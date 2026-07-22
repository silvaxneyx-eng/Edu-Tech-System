#!/usr/bin/env python3
# ============================================================
# EduTech Técnico V4.0 — Multi-Plataforma (Linux & Windows)
# Interface usando CustomTkinter para rodar em qualquer lugar
# ============================================================

import sys
import os
import platform
import subprocess
import threading

# Tenta importar customtkinter. Se falhar, faz fallback automático para o Zenity (menu-tecnico.sh).
try:
    import customtkinter as ctk
except ImportError:
    SCRIPT_DIR = os.path.dirname(os.path.realpath(__file__))
    zenity_script = os.path.join(SCRIPT_DIR, "menu-tecnico.sh")
    if os.path.exists(zenity_script):
        os.execv("/bin/bash", ["bash", zenity_script])
    elif os.path.exists("/home/jardson/Scripts/menu-tecnico.sh"):
        os.execv("/bin/bash", ["bash", "/home/jardson/Scripts/menu-tecnico.sh"])
    else:
        print("ERRO: A biblioteca 'customtkinter' não está instalada.")
        sys.exit(1)

# Modo Escuro Global
ctk.set_appearance_mode("Dark")
ctk.set_default_color_theme("blue")

SCRIPT_DIR = os.path.dirname(os.path.realpath(__file__))
IS_WINDOWS = platform.system() == "Windows"

if not os.path.exists(os.path.join(SCRIPT_DIR, "menu-tecnico.sh")) and not IS_WINDOWS:
    SCRIPT_DIR = "/usr/local/lib/iso-louca/"

class TerminalWindow(ctk.CTkToplevel):
    def __init__(self, parent, tool, *args, **kwargs):
        super().__init__(parent, *args, **kwargs)
        self.title(tool["name"])
        self.geometry("850x600")
        
        # Faz a janela ser modal
        self.transient(parent)
        self.grab_set()

        # Verifica restrição de SO
        if IS_WINDOWS and tool.get("linux_only", False):
            lbl = ctk.CTkLabel(self, text="⚠️ Esta ferramenta não pode ser usada no Windows em execução.\nDê boot pelo pendrive da ISO Louca para usar ferramentas de sistema (Wipe, Boot, etc).", font=("Arial", 16), text_color="#ef4444")
            lbl.pack(expand=True, padx=20, pady=20)
            return

        self.grid_rowconfigure(0, weight=1)
        self.grid_columnconfigure(0, weight=1)

        # Textbox para output do terminal
        self.textbox = ctk.CTkTextbox(self, font=("Consolas", 13), fg_color="#1e1e2e", text_color="#cdd6f4")
        self.textbox.grid(row=0, column=0, columnspan=2, padx=10, pady=(10, 5), sticky="nsew")
        self.textbox.configure(state="disabled")

        # Input do usuário (para enviar dados ao script bash/bat)
        self.input_entry = ctk.CTkEntry(self, placeholder_text="Digite sua resposta aqui e aperte ENTER...")
        self.input_entry.grid(row=1, column=0, padx=10, pady=5, sticky="ew")
        self.input_entry.bind("<Return>", self.on_input_submit)

        # Botão de Cancelar
        self.btn_cancel = ctk.CTkButton(self, text="Forçar Parada", fg_color="#ef4444", hover_color="#dc2626", command=self.force_stop)
        self.btn_cancel.grid(row=1, column=1, padx=10, pady=5, sticky="e")

        # Status Bar
        self.status_lbl = ctk.CTkLabel(self, text="⏳ Executando...", text_color="#f59e0b", font=("Arial", 12, "bold"))
        self.status_lbl.grid(row=2, column=0, columnspan=2, padx=10, pady=(0, 10), sticky="w")

        # Configura Comando
        self.process = None
        cmd = tool["script"]
        
        if IS_WINDOWS:
            # Tenta usar a versão .bat / .ps1 no Windows se existir
            win_script = tool.get("win_script")
            if win_script:
                script_path = os.path.join(SCRIPT_DIR, win_script)
                if win_script.endswith(".ps1"):
                    cmd = f'powershell -ExecutionPolicy Bypass -File "{script_path}"'
                else:
                    cmd = f'cmd.exe /c "{script_path}"'
        else:
            # Lógica Linux
            if tool.get("sudo", False):
                if os.path.exists(os.path.join(SCRIPT_DIR, cmd.split()[0])):
                    cmd = f"sudo bash '{os.path.join(SCRIPT_DIR, cmd.split()[0])}'"
                else:
                    cmd = f"sudo {cmd}"
            else:
                if os.path.exists(os.path.join(SCRIPT_DIR, cmd.split()[0])):
                    cmd = f"bash '{os.path.join(SCRIPT_DIR, cmd.split()[0])}'"

        self.cmd = cmd
        
        # Thread para rodar o processo sem travar a UI
        self.run_thread = threading.Thread(target=self.run_process)
        self.run_thread.daemon = True
        self.run_thread.start()

    def run_process(self):
        try:
            self.process = subprocess.Popen(
                self.cmd,
                shell=True,
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                bufsize=1,
                universal_newlines=True
            )
            
            while True:
                char = self.process.stdout.read(1)
                if not char and self.process.poll() is not None:
                    break
                if char:
                    self.append_text(char)
                    
            ret = self.process.poll()
            if ret == 0:
                self.status_lbl.configure(text="✅ Concluído com sucesso!", text_color="#10b981")
            elif ret == -9 or ret == 9:
                self.status_lbl.configure(text="⛔ Processo cancelado pelo usuário", text_color="#ef4444")
            else:
                self.status_lbl.configure(text=f"⚠️ Finalizado com código de erro {ret}", text_color="#ef4444")
                
            self.input_entry.configure(state="disabled")
            self.btn_cancel.configure(state="disabled")
            
        except Exception as e:
            self.append_text(f"\nErro ao iniciar: {str(e)}\n")
            self.status_lbl.configure(text="❌ Erro crítico", text_color="#ef4444")

    def append_text(self, text):
        self.textbox.configure(state="normal")
        self.textbox.insert("end", text)
        self.textbox.see("end")
        self.textbox.configure(state="disabled")

    def on_input_submit(self, event=None):
        text = self.input_entry.get()
        if self.process and self.process.poll() is None:
            try:
                self.process.stdin.write(text + "\n")
                self.process.stdin.flush()
                self.append_text(text + "\n")
            except Exception:
                pass
        self.input_entry.delete(0, 'end')

    def force_stop(self):
        if self.process and self.process.poll() is None:
            try:
                self.process.terminate()
                self.process.kill()
                self.append_text("\n\n[PROCESSO FORÇADO A PARAR PELO TÉCNICO]\n")
            except Exception:
                pass


class EduTechApp(ctk.CTk):
    def __init__(self):
        super().__init__()
        self.title("EduTech Técnico V4.0")
        self.geometry("900x700")

        # Grid principal
        self.grid_rowconfigure(0, weight=1)
        self.grid_columnconfigure(1, weight=1)

        # Categorias e Ferramentas (Agora com fallback para Windows)
        self.categories = [
            {
                "title": "Discos",
                "groups": [
                    {
                        "title": "Gerenciamento Automático",
                        "tools": [
                            {"name": "Montar Discos Automático", "desc": "Monta partições no Linux", "script": "montar-discos-automatico.sh", "sudo": True, "linux_only": True},
                            {"name": "Backup de Perfil Automático", "desc": "Copia pasta Users do cliente", "script": "backup-perfil-automatico.sh", "sudo": True, "win_script": "win-backup.ps1"},
                        ]
                    },
                    {
                        "title": "Avançado e Recuperação",
                        "tools": [
                            {"name": "Recuperação de Dados Deletados", "desc": "Usa PhotoRec para varrer e recuperar fotos", "script": "recupera-dados.sh", "sudo": True, "linux_only": True},
                            {"name": "Clonagem Completa de Discos", "desc": "Cópia exata de HD para SSD (Irreversível)", "script": "clonar-disco.sh", "sudo": True, "linux_only": True},
                            {"name": "Limpeza Segura de Disco", "desc": "Zera o HD de forma irrecuperável", "script": "limpeza-segura-disco.sh", "sudo": True, "linux_only": True},
                        ]
                    }
                ]
            },
            {
                "title": "Segurança",
                "groups": [
                    {
                        "title": "Manutenção",
                        "tools": [
                            {"name": "Resetar Senhas (Multi-SO)", "desc": "Remove senhas do Windows, Linux e Mac offline", "script": "resetar-senha-automatico.sh", "sudo": True, "linux_only": True},
                            {"name": "Scanner de Vírus Offline", "desc": "Escaneia com ClamAV sem ligar o Windows", "script": "scanner-virus-offline.sh", "sudo": True, "linux_only": True},
                        ]
                    },
                    {
                        "title": "Reparos",
                        "tools": [
                            {"name": "Reparo de Boot Windows", "desc": "Recria BCD e MBR/EFI do Windows", "script": "reparo-boot-windows.sh", "sudo": True, "linux_only": True},
                            {"name": "Reparo de GRUB Linux", "desc": "Reinstala o GRUB no disco", "script": "reparo-grub.sh", "sudo": True, "linux_only": True},
                        ]
                    }
                ]
            },
            {
                "title": "Multiboot (WPE)",
                "groups": [
                    {
                        "title": "Instalação & ISOs",
                        "tools": [
                            {"name": "Lançador e Instalador de ISOs", "desc": "Detecta e instala/inicia ISOs do Windows ou Linux", "script": "iso-launcher.sh", "sudo": True, "linux_only": True},
                            {"name": "Ghost Toolbox Rev11", "desc": "Instalador e otimizador da Ghost Spectre (Windows/Wine)", "script": "wine /home/jardson/Tools/GhostToolbox/Ghost.Toolbox-Rev11_setup.x64.exe 2>/dev/null || wine '/run/media/jardson/VENTOY/Ghost Toolbox/Ghost.Toolbox-Rev11_setup.x64.exe'", "sudo": False, "win_script": "Ghost.Toolbox-Rev11_setup.x64.exe"},
                        ]
                    }
                ]
            },
            {
                "title": "Rede & Info",
                "groups": [
                    {
                        "title": "Diagnóstico",
                        "tools": [
                            {"name": "Informações do Hardware", "desc": "CPU, RAM, Placa-mãe", "script": "inxi -F 2>/dev/null || sudo lshw -short 2>/dev/null || (lscpu; free -h; lsblk)", "sudo": False, "win_script": "win-hardware.ps1"},
                            {"name": "Diagnóstico S.M.A.R.T", "desc": "Verifica saúde física do HD/NVMe", "script": "diagnostico-discos.sh", "sudo": True, "linux_only": True},
                            {"name": "Scanner de Rede Local", "desc": "Mapeia IPs e portas na rede", "script": "scanner-rede.sh", "sudo": True, "win_script": "win-network.ps1"},
                        ]
                    }
                ]
            }
        ]

        # Barra Lateral
        self.sidebar_frame = ctk.CTkFrame(self, width=200, corner_radius=0)
        self.sidebar_frame.grid(row=0, column=0, sticky="nsew")
        self.sidebar_frame.grid_rowconfigure(4, weight=1)

        self.logo_label = ctk.CTkLabel(self.sidebar_frame, text="⚙️ EduTech", font=ctk.CTkFont(size=20, weight="bold"))
        self.logo_label.grid(row=0, column=0, padx=20, pady=(20, 30))

        # View Principal
        self.main_frame = ctk.CTkFrame(self, corner_radius=0, fg_color="transparent")
        self.main_frame.grid(row=0, column=1, sticky="nsew")
        self.main_frame.grid_columnconfigure(0, weight=1)

        self.category_buttons = []
        for i, cat in enumerate(self.categories):
            btn = ctk.CTkButton(self.sidebar_frame, text=cat["title"], fg_color="transparent", text_color=("gray10", "gray90"), hover_color=("gray70", "gray30"), anchor="w", command=lambda idx=i: self.select_category(idx))
            btn.grid(row=i+1, column=0, padx=10, pady=5, sticky="ew")
            self.category_buttons.append(btn)

        self.select_category(0)

    def select_category(self, idx):
        # Atualiza estilo dos botões
        for i, btn in enumerate(self.category_buttons):
            btn.configure(fg_color="#3b82f6" if i == idx else "transparent")
            
        # Limpa o main frame
        for child in self.main_frame.winfo_children():
            child.destroy()
            
        cat = self.categories[idx]
        title_lbl = ctk.CTkLabel(self.main_frame, text=cat["title"], font=ctk.CTkFont(size=24, weight="bold"))
        title_lbl.grid(row=0, column=0, padx=20, pady=(20, 10), sticky="w")
        
        row_idx = 1
        for grp in cat["groups"]:
            grp_lbl = ctk.CTkLabel(self.main_frame, text=grp["title"].upper(), font=ctk.CTkFont(size=12, weight="bold"), text_color="#94a3b8")
            grp_lbl.grid(row=row_idx, column=0, padx=20, pady=(20, 5), sticky="w")
            row_idx += 1
            
            # Container do Grupo (estilo cartão)
            grp_frame = ctk.CTkFrame(self.main_frame, fg_color="#1e293b", corner_radius=10)
            grp_frame.grid(row=row_idx, column=0, padx=20, pady=5, sticky="ew")
            grp_frame.grid_columnconfigure(0, weight=1)
            row_idx += 1
            
            for i, tool in enumerate(grp["tools"]):
                tool_frame = ctk.CTkFrame(grp_frame, fg_color="transparent")
                tool_frame.grid(row=i, column=0, padx=15, pady=10, sticky="ew")
                tool_frame.grid_columnconfigure(0, weight=1)
                
                # Desativa visualmente se for Linux-only e rodar no Windows
                disabled = IS_WINDOWS and tool.get("linux_only", False)
                text_color = "gray50" if disabled else "white"
                
                name_lbl = ctk.CTkLabel(tool_frame, text=tool["name"], font=ctk.CTkFont(size=14, weight="bold"), text_color=text_color)
                name_lbl.grid(row=0, column=0, sticky="w")
                
                desc_lbl = ctk.CTkLabel(tool_frame, text=tool["desc"] + (" (Somente via USB)" if disabled else ""), text_color="gray50")
                desc_lbl.grid(row=1, column=0, sticky="w")
                
                btn = ctk.CTkButton(tool_frame, text="▶ Executar", width=100, state="disabled" if disabled else "normal", command=lambda t=tool: self.launch_tool(t))
                btn.grid(row=0, column=1, rowspan=2, padx=10, sticky="e")

    def launch_tool(self, tool):
        win = TerminalWindow(self, tool)

if __name__ == "__main__":
    app = EduTechApp()
    app.mainloop()

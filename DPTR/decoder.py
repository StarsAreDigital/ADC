import re
import tkinter as tk
import tkinter.messagebox
import tkinter.filedialog

class App:
    selected_file: str | None = None
    instr_format = {
        "r": {
            "pattern": re.compile(r"\w+\s+\$(?P<rd>\d+),?\s*\$(?P<rs>\d+),?\s+\$(?P<rt>\d+)"),
            "format": "{op:06b}{rs:05b}{rt:05b}{rd:05b}00000{fnc:06b}"
        },
        "i": {
            "pattern": re.compile(r"\w+\s+\$(?P<rt>\d+),?\s*(?P<offset>\d+)\s*\(\s*\$(?P<base>\d+)\s*\)"),
            "format": "{op:06b}{base:05b}{rt:05b}{offset:016b}"
        },
        "j": {
            "pattern": re.compile(r"\w+\s+(?P<instr_index>\d+)"),
            "format": "{op:06b}{instr_index:026b}"
        },
        "nop": {
            "pattern": re.compile(r"\w+"),
            "format": "00000000000000000000000000000000"
        }
    }

    instructions = {
        "add": {
            "instr_type": "r",
            "op": 0b0,
            "fnc": 0b100000
        },
        "sub": {
            "instr_type": "r",
            "op": 0b0,
            "fnc": 0b100010
        },
        "slt": {
            "instr_type": "r",
            "op": 0b0,
            "fnc": 0b101010
        },
        "or": {
            "instr_type": "r",
            "op": 0b0,
            "fnc": 0b100101      
        },
        "and": {
            "instr_type": "r",
            "op": 0b0,
            "fnc": 0b100100
        },
        "nop": {
            "instr_type": "nop",
        },
        "sw": {
            "instr_type": "i",
            "op": 0b101011
        },
        "lw": {
            "instr_type": "i",
            "op": 0b100011
        },
        "j": {
            "instr_type": "j",
            "op": 0b000010
        }
    }

    def __init__(self):
        self.root = tk.Tk()
        self.root.title("Decodificador de código ensamblador")
        self.root.geometry("400x200")

        select_button = tk.Button(self.root, text="Seleccionar archivo de código ensamblador", command=self.select_file)
        select_button.pack(pady=10)

        self.selected_file_label = tk.Label(self.root, text="Ningún archivo seleccionado", wraplength=350)
        self.selected_file_label.pack(pady=5)

        save_button = tk.Button(self.root, text="Guardar archivo binario", command=self.save_file)
        save_button.pack(pady=10)

        self.root.mainloop()


    def decode_file(self, file_path) -> list:
        res = []
        with open(file_path, 'r') as file:
            for idx, line in enumerate(file):
                instruction = line.strip().partition("#")[0]
                if not instruction:
                    continue
                try:
                    bin_instr = self.parse_instruction(instruction)
                    res.append(
                        bin_instr[0:8] + " " +
                        bin_instr[8:16] + " " +
                        bin_instr[16:24] + " " +
                        bin_instr[24:32]
                    )
                except ValueError as e:
                    tkinter.messagebox.showerror("Error", f"Error en la línea {idx + 1}: {e}")
                    return None
        return res

                
    def parse_instruction(self, instruction) -> str:
        find_instr = r'(\w+).*'
        instr_match = re.match(find_instr, instruction)
        if not instr_match:
            raise ValueError("Formato de instrucción no válido")
        
        instr = instr_match.groups()[0]
        instr_lower = instr.lower()

        if instr_lower not in self.instructions:
            raise ValueError(f"Instrucción '{instr}' no válida")
        
        decode = self.instructions[instr_lower]
        instr_type = decode["instr_type"]
        instr_type = self.instr_format[instr_type]

        match = instr_type["pattern"].match(instruction)

        if not match:
            raise ValueError("Formato de instrucción no válido")
        
        groups = match.groupdict()
        for key in groups:
            groups[key] = int(groups[key])

        groups.update(decode)

        return instr_type["format"].format_map(groups)
                           

    def select_file(self):
        file_path = tkinter.filedialog.askopenfilename(
            title="Selecciona un archivo de código ensamblador",
            filetypes=[("Archivos de ensamblador", "*.asm")]
        )

        if file_path:
            self.selected_file_label.config(text=f"Archivo seleccionado: {file_path}")
            self.selected_file = file_path
        else:
            self.selected_file_label.config(text="Ningún archivo seleccionado")
            self.selected_file = None


    def save_file(self):
        if not self.selected_file:
            tkinter.messagebox.showerror("Error", "No se seleccionó ningún archivo.")
            return

        save_path = tkinter.filedialog.asksaveasfilename(
            title="Guardar como",
            defaultextension=".mem",
            filetypes=[("Archivos de memoria", "*.mem"), ("Archivos de texto", "*.txt"), ("Todos los archivos", "*.*")]
        )

        if not save_path:
            return
        
        result = self.decode_file(self.selected_file)
        if result is None: return

        try:
            with open(save_path, 'w') as outfile:
                if result: 
                    outfile.write(result[0])
                outfile.writelines('\n' + line for line in result[1:])
            tkinter.messagebox.showinfo("Guardado", "Archivo binario guardado exitosamente")
        except Exception as e:
            tkinter.messagebox.showerror("Error", f"Ocurrió un error: {e}")


if __name__ == "__main__":
    App()
